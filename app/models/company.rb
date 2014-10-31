class Company < ActiveRecord::Base
  #FIXME: ROLES constant is not needed here, can be accesses from User class

  resourcify

  #FIXED
  #FIXME : group associations, validations, accessors, callbacks with each other
  has_many :users, dependent: :restrict_with_exception
  has_many :tracks, dependent: :restrict_with_exception
  has_one :owner, through: :owner_role, source: :users
  has_one :owner_role, -> { where(roles: { name: User::ROLES[:account_owner], resource_type: 'Company' }) }, class_name: 'Role', foreign_key: :resource_id

  attr_accessor :owner_email, :owner_name

  before_validation :build_owner, on: :create
  after_create :make_owner

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true

  scope :load_with_owners, -> { includes(:owner) }
  scope :enabled, -> { where(enabled: true) }


    #FIXED
    #FIXME_AB: Don't hard code role use ROLES array/hash constant
    # FIXME : Return active record from here
    #FIXED
    #FIXME_AB: should not use .first here, return the arel object

  private
    def build_owner
      #Here we are creating a owner before a company is created we cannot use this syntax
      #FIXME_AB: I don't agree with your comment above, this create a user a global account owner.
      #FIXME_AB: This is wrong, when you are building the owner you should pass a second argument to the add_role. For example user.add_role(ROLES[:account_owner], @company) so that user would be owner of the current company not a global owner for all company.
      @owner = users.build(name: owner_name, email: owner_email)
      #FIXME_AB: Don't hard code role use ROLES array/hash constant
    end

    def make_owner
      @owner.try(:add_role, User::ROLES[:account_owner], self)
    end
end
