class Company < ActiveRecord::Base

  has_many :users, inverse_of: :company, dependent: :destroy

  attr_accessor :owner_email, :owner_name

  before_validation :build_owner

  ## FIXME_NISH Lets make an association of owner as discussed and also validate that there is always only one owner.

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true

  scope :load_with_owners, -> { eager_load(:users).joins(users: :roles).merge(Role.with_name('account_owner')) }


  def owner
    users.with_account_owner_role.first
  end

  private
    def build_owner
      users.build(name: owner_name, email: owner_email).add_role(:account_owner)
    end

  # FIXED
  ## FIXME_NISH why this callback is a after_commit?
  ## FIXME_NISH Please move this callback to user as discussed.
end
