class Company < ActiveRecord::Base
  has_many :users, dependent: :restrict_with_exception

  attr_accessor :owner_email, :owner_name

  before_validation :build_owner, on: :create

  validates :name, presence: true

  #FIXME_AB: we would also need a scope :enabled
  #FIXED
  #FIXME Change rspecs of this scope and below methods as discussed.
  validates :name, uniqueness: { case_sensitive: false }, allow_blank: true
  #FIXED
  #FIXME Write rspec for eagerload also.
  scope :load_with_owners, -> { eager_load(:users).joins(users: :roles).merge(Role.with_name('account_owner')) }


  def owner
    #FIXME_AB: should not use .first here, return the arel object
    users.with_account_owner_role.first
  end

  private
    def build_owner
      #FIXME_AB: This is wrong, when you are building the owner you should pass a second argument to the add_role. For example user.add_role(:account_owner, @company) so that user would be owner of the current company not a global owner for all company.
      users.build(name: owner_name, email: owner_email).add_role(:account_owner)
    end
end
