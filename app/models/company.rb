class Company < ActiveRecord::Base
  has_many :users
  validates :name, presence: true, uniqueness: true
  accepts_nested_attributes_for :users

  def owner_email
    users.owner.first.email
  end

end
