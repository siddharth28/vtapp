class Company < ActiveRecord::Base
  has_many :users, dependent: :restrict_with_exception

  attr_accessor :owner_email, :owner_name

  before_validation :build_owner, on: :create

  validates :name, presence: true

  #FIXED
  #FIXME Change rspecs of this scope and below methods as discussed.
  validates :name, uniqueness: { case_sensitive: false }, allow_blank: true
  #FIXED
  #FIXME Write rspec for eagerload also.
  #FIXME_AB: Don't hard code role use ROLES array/hash constant
  scope :load_with_owners, -> { eager_load(:users).joins(users: :roles).merge(Role.with_name('account_owner')) }
  scope :enabled, -> { where(enabled: true) }

  def owner
      #FIXME_AB: Don't hard code role use ROLES array/hash constant

    users.with_role(:account_owner)
  end

  private
    def build_owner
      #Here we are creating a owner before a company is created we cannot use this syntax
      #FIXME_AB: I don't agree with your comment above, this create a user a global account owner.
      #FIXME_AB: This is wrong, when you are building the owner you should pass a second argument to the add_role. For example user.add_role(:account_owner, @company) so that user would be owner of the current company not a global owner for all company.
      users.build(name: owner_name, email: owner_email).add_role(:account_owner)
        #FIXME_AB: Don't hard code role use ROLES array/hash constant

    end
end
