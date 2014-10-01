require 'mailer'
class User < ActiveRecord::Base
  ## FIXED 
  ## FIXME_NISH Please move the devise and rolify to the top of the model.
  rolify
  devise :database_authenticatable, :registerable, :async,
    :recoverable, :rememberable, :trackable, :validatable

  ## FIXED 
  ## FIXME_NISH Please specify dependent condition with associations.
  has_many :mentees, class_name: 'User', foreign_key: "mentor_id", dependent: :nullify

  belongs_to :company
  belongs_to :mentor, class_name: 'User'

  ## FIXED 
  ## FIXME_NISH Why we have made name as readonly?
  attr_readonly :email, :company_id

  validates :mentor, presence: true, if: :mentor_id?

  before_validation :set_random_password, on: :create

  ## FIXED 
  ## FIXME_NISH Please find the correct callback for the method.
  after_create :send_password_email

  scope :owner, -> { joins(:roles).merge(Role.with_name('account_owner')) }

  def active_for_authentication?
    if has_role? :super_admin
      super
    else
      super && enabled && company.enabled
    end
  end

  private
    def set_random_password
      ## FIXED
      ## FIXME_NISH Also, set self.password_confirmation.
      self.password_confirmation = self.password = Devise.friendly_token.first(8)
    end

    def send_password_email
      Mailer.send_email(self)
    end
end
