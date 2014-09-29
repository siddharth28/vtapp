class User < ActiveRecord::Base
  ## FIXME_NISH Please specify dependent condition with associations.
  has_many :mentees, class_name: 'User', foreign_key: "mentor_id"

  belongs_to :company
  belongs_to :mentor, class_name: 'User'

  ## FIXME_NISH Why we have made name as readonly?
  attr_readonly :name, :email, :company_id

  validates :mentor, presence: true, if: :mentor_id?

  before_validation :set_random_password, on: :create

  ## FIXME_NISH Please find the correct callback for the method.
  after_create :send_password_email

  ## FIXME_NISH Please move the devise and rolify to the top of the model.

  rolify
  devise :database_authenticatable, :registerable, :async,
    :recoverable, :rememberable, :trackable, :validatable

  scope :owner, -> { joins(:roles).merge(Role.find_role('account_owner')) }

  def set_random_password
    ## FIXME_NISH Also, set self.password_confirmation.
    self.password = Devise.friendly_token.first(8)
  end

  def send_password_email
    ## FIXME_NISH Refactor this code.
    ## FIXME_NISH Create a lib file to call mailers.
    user_email = self.email
    password = self.password
    UserMailer.delay.welcome_email(user_email, password)
  end

  def active_for_authentication?
    if has_role? :super_admin
      super
    else
      super && enabled && company.enabled
    end
  end
end
