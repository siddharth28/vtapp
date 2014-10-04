class Company < ActiveRecord::Base

  has_many :users, dependent: :destroy
  has_one :owner, -> { joins(:roles).where('roles.name' => 'account_owner') }, class_name: 'User'

  accepts_nested_attributes_for :users

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true


  ## FIXME_NISH why this callback is a after_commit?
  ## FIXME_NISH Please move this callback to user as discussed.

  ## FIXME_NISH Lets make an association of owner as discussed and also validate that there is always only one owner.
end
