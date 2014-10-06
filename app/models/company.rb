class Company < ActiveRecord::Base

  has_many :users, dependent: :destroy

  ## FIXME_NISH Lets make an association of owner as discussed and also validate that there is always only one owner.

  accepts_nested_attributes_for :users

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true

  def owner
    users.first
  end

  # FIXED
  ## FIXME_NISH why this callback is a after_commit?
  ## FIXME_NISH Please move this callback to user as discussed.
end
