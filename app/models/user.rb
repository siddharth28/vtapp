class User < ActiveRecord::Base
  belongs_to :company
  rolify
  before_validation :set_random_password, on: :create
  after_create :send_password_email
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  scope :owner, -> { joins(:roles).merge(Role.find_role('account_owner')) }

  def set_random_password
    self.password = Devise.friendly_token.first(8)
  end

  def send_password_email
    user_email = self.email
    password = self.password
    UserMailer.delay.welcome_email(user_email, password)
  end
  # handle_asynchronously :send_password_email
end
