class Track < ActiveRecord::Base

  ROLES = { track_owner: :track_owner, track_reviewer: :track_reviewer, track_runner: :track_runner }

  resourcify

  belongs_to :company
  has_one :owner, through: :owner_role, source: :users
  has_one :owner_role, -> { where(roles: { name: Track::ROLES[:track_owner], resource_type: 'Track' }) }, class_name: 'Role', foreign_key: :resource_id
  has_many :tasks, dependent: :destroy
  has_many :reviewer_role, -> { where(roles: { name: Track::ROLES[:track_reviewer], resource_type: 'Track' }) }, class_name: 'Role', foreign_key: :resource_id
  has_many :reviewers, through: :reviewer_role, source: :users

  after_create :assign_track_owner_role

  validates :company, :references, :description, :instructions, presence: true
  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }, presence: true, length: { maximum: 255 }
  validates :owner_id, presence: true, on: :update

  attr_accessor :owner_id, :owner_name, :reviewer_id, :reviewer_name

  strip_fields :name

  scope :load_with_owners, -> { includes(:owner) }

  def self.extract(type, user)
    role = "track_#{ type }".to_sym
    with_roles(role, user)
  end

  def add_track_role(role, user_id)
    if user_id.blank?
      add_error(:base, "can't be blank")
    else
      user = find_user(user_id)
      user.add_role(ROLES[role], self)
    end
  end

  def remove_track_role(role, user_id)
    find_user(user_id).remove_role(ROLES[role], self)
  end

  def assign_track_owner_role
    user = find_user(owner_id) || company.owner
    user.add_role(ROLES[:track_owner], self)
  end

  def replace_owner(owner_id)
    remove_track_role(ROLES[:track_owner], owner)
    add_track_role(ROLES[:track_owner], owner_id)
  end

  private
    def add_error(field, error)
      errors[:base] = error
    end

    def find_user(user_id)
      company_users.find_by(id: user_id)
    end

    def company_users
      company.users
    end
end
