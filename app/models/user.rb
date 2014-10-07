# FIXED
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
  validates :company, presence: true, if: -> { !super_admin? }
  validates :name, presence: true
  ## FIXME Please change its name and use before_destroy
  ## FIXME Also add validation for account_owner cannot be changed.
  before_destroy :ensure_an_account_owners_and_super_admin_remains

  before_validation :set_random_password, on: :create

  after_create :send_password_email

  scope :with_account_owner_role, -> { joins(:roles).merge(Role.with_name('account_owner')) }

  def active_for_authentication?
    if super_admin?
      super
    else
      super && enabled && company.enabled
    end
  end

  def super_admin?
    has_role? :super_admin
  end

  def account_owner?
    has_role? :account_owner
  end

  private
    def set_random_password
      self.password_confirmation = self.password = Devise.friendly_token.first(8)
    end

    def send_password_email
      password = self.password
      UserMailer.delay.welcome_email(self.email, password)
    end

    # FIXED
    ## FIXME We can also call has_role? method without self.
    def ensure_an_account_owners_and_super_admin_remains
      if super_admin?
        raise "Can't delete Super Admin"
      elsif account_owner?
        raise "Can't delete Account Owner"
      end
    end

    def ensure_only_one_account_owner(role)
      if role.name == 'account_owner'
        if company.owner
          raise 'there can be only one acccount owner'
        end
      end
    end
end