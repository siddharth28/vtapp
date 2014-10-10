class Company < ActiveRecord::Base
  #FIXED
  #FIXME Check whether inverse_of required or not.
  has_many :users, dependent: :restrict_with_exception

  #FIXED
  #FIXME Write rspecs for attr_accessors
  attr_accessor :owner_email, :owner_name

  before_validation :build_owner, on: :create

  validates :name, presence: true
  #FIXME_AB: What about case matching
  validates :name, uniqueness: true, allow_blank: true

  #FIXME_AB: we would also need a scope :enabled
  #FIXED
  #FIXME Change rspecs of this scope and below methods as discussed.
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
