class Company < ActiveRecord::Base
  #FIXED
  #FIXME Check whether inverse_of required or not.
  has_many :users, dependent: :restrict_with_exception

  #FIXME Write rspecs for attr_accessors
  attr_accessor :owner_email, :owner_name

  before_validation :build_owner, on: :create

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true

  #FIXME Change rspecs of this scope and below methods as discussed.

  scope :load_with_owners, -> { eager_load(:users).joins(users: :roles).merge(Role.with_name('account_owner')) }


  def owner
    users.with_account_owner_role.first
  end

  private
    def build_owner
      users.build(name: owner_name, email: owner_email).add_role(:account_owner)
    end
end
