class User < ActiveRecord::Base
  belongs_to :company
  rolify
  before_validation :set_random_password, on: :create
  after_create :send_password_email
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def set_random_password
    self.password = Devise.friendly_token.first(8)
  end

  def send_password_email
    UserMailer.welcome_email(self).deliver
  end
end
