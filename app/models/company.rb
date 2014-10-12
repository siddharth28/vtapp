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
  scope :load_with_owners, -> { eager_load(:users).joins(users: :roles).merge(Role.with_name('account_owner')) }
  #FIXED with rspec : 72
  #FIXME_AB: we would also need a scope :enabled
  scope :enabled, -> { where(enabled: true) }

  def owner
    #FIXED
    #FIXME_AB: should not use .first here, return the arel object
    users.with_role(:account_owner)
  end

  private
    def build_owner
      #Here we are creating a owner before a company is created we cannot use this syntax
      #FIXME_AB: This is wrong, when you are building the owner you should pass a second argument to the add_role. For example user.add_role(:account_owner, @company) so that user would be owner of the current company not a global owner for all company.
      users.build(name: owner_name, email: owner_email).add_role(:account_owner)
    end
end
