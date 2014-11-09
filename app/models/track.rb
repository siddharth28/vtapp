class Track < ActiveRecord::Base

  ROLES = { track_owner: :track_owner, track_reviewer: :track_reviewer, track_runner: :track_runner }

  resourcify

  belongs_to :company
  has_one :owner_role, -> { where(roles: { name: Track::ROLES[:track_owner], resource_type: 'Track' }) }, class_name: 'Role', foreign_key: :resource_id
  has_one :owner, through: :owner_role, source: :users
  has_many :tasks, dependent: :destroy
  has_many :reviewer_role, -> { where(roles: { name: Track::ROLES[:track_reviewer], resource_type: 'Track' }) }, class_name: 'Role', foreign_key: :resource_id
  has_many :reviewers, through: :reviewer_role, source: :users

  after_create :assign_track_owner_role

  # FIXED
  # FIXME : presence validations can ve clubbed in one
  validates :references, :description, :instructions, presence: true
  validates :name, uniqueness: { scope: [:company_id], case_sensitive: false }, presence: true, length: { maximum: 255 }

  attr_accessor :owner_id, :owner_name, :reviewer_id, :reviewer_name

  strip_fields :name

  scope :load_with_owners, -> { includes(:owner) }

  def self.extract(type, user)
    role = "track_#{ type }".to_sym
    with_roles(role, user)
  end

  # FIXED
  # FIXME : method name should be plural as it returns activerelation

  def add_track_role(role, user_id)
    user = find_user(user_id)
    # FIXME : dynamic track_runner? method can be used here
    # FIXME : No need to check for role here.
    user.add_role(ROLES[role], self)
  end

  def remove_track_role(role, user_id)
    find_user(user_id).remove_role(ROLES[role], self)
  end

  def assign_track_owner_role
    #FIXED
    # FIXME : This code can be simplified
    if company_users.ids.include?(owner_id.to_i)
      user = find_user(owner_id)
    else
      user = company.owner
    end
    user.try(:add_role, ROLES[:track_owner], self)
  end

  private
    def find_user(user_id)
      company_users.find_by(id: user_id)
    end

    def company_users
      company.users
    end
end
