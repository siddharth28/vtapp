## FIXME_NISH Please provide an appropriate name for mailer
## FIXME_NISH require lib files in application, we don't need to require them separately.
class User < ActiveRecord::Base
  rolify before_add: :ensure_only_one_account_owner
  devise :database_authenticatable, :registerable, :async,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :mentees, class_name: 'User', foreign_key: "mentor_id", dependent: :nullify

  belongs_to :company
  belongs_to :mentor, class_name: 'User'

  attr_readonly :email, :company_id

  validates :mentor, presence: true, if: :mentor_id?
  validates :company, presence: true
  after_destroy :ensure_an_account_owners_and_super_admin_remains

  before_validation :set_random_password, on: :create

  # FIXED
  ## FIXME_NISH Please find the correct callback for the method.
  after_create :send_password_email, :add_role_account_owner_if_first_user

  def active_for_authentication?
    if has_role? :super_admin
      super
    else
      super && enabled && company.enabled
    end
  end

  private
    def set_random_password
      self.password_confirmation = self.password = Devise.friendly_token.first(8)
    end

    def send_password_email
      email = self.email
      password = self.password
      UserMailer.delay.welcome_email(email, password)
    end

    def ensure_an_account_owners_and_super_admin_remains
      if self.has_role? :super_admin
        raise "Can't delete Super Admin"
      elsif self.has_role? :account_owner
        raise "Can't delete Account Owner"
      end
    end

    def ensure_only_one_account_owner(role)
      if role.name == 'account_owner'
        if self.company.owner.has_role? :acccount_owner
          raise 'there can be only one acccount owner'
        end
      end
    end

    def add_role_account_owner_if_first_user
      if company.users.length == 1
        add_role :account_owner
      end
    end
end
