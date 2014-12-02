class Company < ActiveRecord::Base
  resourcify

  has_many :users, dependent: :restrict_with_exception
  has_many :tracks, dependent: :restrict_with_exception
  has_one :owner, through: :owner_role, source: :users
  ## FIXME_NISH Please use the scope created for this.
  has_one :owner_role, -> { where(roles: { name: User::ROLES[:account_owner], resource_type: 'Company' }) }, class_name: 'Role', foreign_key: :resource_id
  attr_accessor :owner_email, :owner_name

  before_validation :build_owner, on: :create
  after_create :make_owner

  ## FIXME_NISH Add a validation for owner presence.
  validates :name, presence: true
  ## FIXME_NISH Add a constant for name length.
  validates :name, uniqueness: { case_sensitive: false }, length: { maximum: 255 }, allow_blank: true

  strip_fields :name
  ## FIXED
  ## FIXME_NISH This scope is not required we can directly write includes(:owner) wherever it is required.
  scope :enabled, -> { where(enabled: true) }

  private
    def build_owner
      @owner = users.build(name: owner_name, email: owner_email)
    end

    def make_owner
      @owner.try(:add_role, User::ROLES[:account_owner], self)
    end
end
