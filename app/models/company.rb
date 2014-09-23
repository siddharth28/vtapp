class Company < ActiveRecord::Base
  has_many :users
  validates :name, presence: true, uniqueness: true
  accepts_nested_attributes_for :users

  def owner_email(id)
    User.owner(id).email
  end

end
