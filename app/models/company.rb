class Company < ActiveRecord::Base

  has_many :users, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true

  accepts_nested_attributes_for :users

  ## FIXME_NISH why this callback is a after_commit?
  ## FIXME_NISH Please move this callback to user as discussed.
  after_commit :make_owner, on: :create

  ## FIXME_NISH Lets make an association of owner as discussed and also validate that there is always only one owner.
  def owner
    users.owner.first
  end
  private
    def make_owner
      users.first.add_role(:account_owner)
    end
end
