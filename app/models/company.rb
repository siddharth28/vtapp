class Company < ActiveRecord::Base

  has_many :users, dependent: :destroy

  ## FIXME_NISH Lets make an association of owner as discussed and also validate that there is always only one owner.
  has_one :owner, -> { joins(:roles).merge(Role.with_name('account_owner')) }, class_name: 'User'

  accepts_nested_attributes_for :users

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true

  # FIXED
  ## FIXME_NISH why this callback is a after_commit?
  ## FIXME_NISH Please move this callback to user as discussed.
end
