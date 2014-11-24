class Company < ActiveRecord::Base
  resourcify

  has_many :users, dependent: :restrict_with_exception
  has_many :tracks, dependent: :restrict_with_exception
  has_one :owner, through: :owner_role, source: :users
  has_one :owner_role, -> { where(roles: { name: User::ROLES[:account_owner], resource_type: 'Company' }) }, class_name: 'Role', foreign_key: :resource_id
  attr_accessor :owner_email, :owner_name

  before_validation :build_owner, on: :create
  after_create :make_owner

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }

  strip_fields :name

  scope :load_with_owners, -> { includes(:owner) }
  scope :enabled, -> { where(enabled: true) }

  private
    def build_owner
      @owner = users.build(name: owner_name, email: owner_email)
    end

    def make_owner
      @owner.try(:add_role, User::ROLES[:account_owner], self)
    end
end
