#FIXED
#FIXME Write rspecs for missing things.
class User < ActiveRecord::Base
  rolify before_add: :ensure_only_one_account_owner, before_remove: :ensure_cannot_remove_account_owner_role
  devise :database_authenticatable, :registerable, :async,
    :recoverable, :rememberable, :trackable, :validatable

  #FIXME_AB: as discussed we should not allow to delete user/any_record if it has dependent objects. so use dependent restrict
  has_many :mentees, class_name: 'User', foreign_key: "mentor_id", dependent: :nullify

  belongs_to :company
  belongs_to :mentor, class_name: 'User'

  attr_readonly :email, :company_id
  #FIXED
  #FIXME Write rspecs of mentor and company using context.
  validates :mentor, presence: true, if: :mentor_id?
  validates :company, presence: true, if: -> { !super_admin? }
  validates :name, presence: true
  validates :password, :password_confirmation, :current_password, presence: true, on: :update
  #FIXME_AB: no validation on email
  ## FIXED
  ## FIXME Also add validation for account_owner cannot be changed.

  before_destroy :ensure_an_account_owners_and_super_admin_remains

  before_validation :set_random_password, on: :create

  after_commit :send_password_email, on: :create

  #FIXME_AB: Why can't we User.with_role(:account_owner). Rollify already provides this. Why we need custom scope.
  scope :with_account_owner_role, -> { joins(:roles).merge(Role.with_name('account_owner')) }

  def active_for_authentication?
    if super_admin?
      super
    else
      super && enabled && company.enabled
    end
  end

  ['account_owner', 'super_admin'].each do |method|
    define_method "#{ method }?" do
      has_role? "#{ method }"
    end
  end

  private
    def set_random_password
      self.password_confirmation = self.password = Devise.friendly_token.first(8)
    end

    def send_password_email
      password = self.password
      email = self.email
      UserMailer.delay.welcome_email(email, password)
    end

    def ensure_an_account_owners_and_super_admin_remains
      if super_admin?
        raise "Can't delete Super Admin"
      elsif account_owner?
        raise "Can't delete Account Owner"
      end
    end
    #rolify callback
    #FIXME_AB: why are we raising exceptoins from callbacks. would returning false not help? Also, if raising exception is only solution, we should handle the exception.
    def ensure_only_one_account_owner(role)
      #FIXME_AB: Lets maintain a constant array of all roles and use that, instead of hard coding roles.
      if role.name == 'account_owner'
        if company.owner
          #FIXME_AB: WE can avoid this nested if statement.
          raise 'There can be only one account owner'
        end
      end
    end
    #rolify callback
    def ensure_cannot_remove_account_owner_role(role)
      if role.name == 'account_owner'
        raise 'Cannot remove account_owner role'
      end
    end
end
