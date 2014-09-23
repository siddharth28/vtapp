class User < ActiveRecord::Base
  belongs_to :company
  rolify
  before_validation :set_random_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def set_random_password
    self.password = ('0'..'z').to_a.shuffle.first(8).join
  end
end
