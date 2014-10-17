class Company < ActiveRecord::Base
  resourcify
  ROLES = { account_owner: :account_owner }
  has_many :users, dependent: :restrict_with_exception
  has_many :tracks, dependent: :restrict_with_exception
  attr_accessor :owner_email, :owner_name

  before_validation :build_owner, on: :create
  after_create :make_owner

  validates :name, presence: true

  validates :name, uniqueness: { case_sensitive: false }, allow_blank: true

  #FIXME_AB: Don't hard code role use ROLES array/hash constant

  scope :load_with_owners, -> { eager_load(:users).joins(:users).merge(User.with_role(ROLES[:account_owner], :any)) }
  scope :enabled, -> { where(enabled: true) }

  def owner
      #FIXME_AB: Don't hard code role use ROLES array/hash constant
    users.with_role(ROLES[:account_owner], self)
    #FIXED
    #FIXME_AB: should not use .first here, return the arel object
  end

  private
    def build_owner
      #Here we are creating a owner before a company is created we cannot use this syntax
      #FIXME_AB: I don't agree with your comment above, this create a user a global account owner.
      #FIXME_AB: This is wrong, when you are building the owner you should pass a second argument to the add_role. For example user.add_role(ROLES[:account_owner], @company) so that user would be owner of the current company not a global owner for all company.
      @owner = users.build(name: owner_name, email: owner_email)
      #FIXME_AB: Don't hard code role use ROLES array/hash constant
    end
    def make_owner
      @owner.add_role(ROLES[:account_owner], self)
    end
end
