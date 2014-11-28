class Track < ActiveRecord::Base

  ROLES = { track_owner: 'track_owner', track_reviewer: 'track_reviewer', track_runner: 'track_runner' }.with_indifferent_access

  resourcify

  belongs_to :company
  has_one :owner, through: :owner_role, source: :users
  ## FIXME_NISH Please create a scope for this and reuse it in reviewer_role.
  has_one :owner_role, -> { track_with_role(Track::ROLES[:track_owner]) }, class_name: 'Role', foreign_key: :resource_id
  has_many :tasks, dependent: :destroy
  has_many :reviewer_role, -> { where(roles: { name: Track::ROLES[:track_reviewer], resource_type: 'Track' }) }, class_name: 'Role', foreign_key: :resource_id
  has_many :reviewers, through: :reviewer_role, source: :users

  after_create :assign_track_owner_role

  validates :company, :references, :description, :instructions, presence: true
  ## FIXME_NISH Please break the validation into multiple validations because this will fire a query even if there is nil value for title.
  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }, presence: true, length: { maximum: 255 }
  ## FIXME_NISH We should not validate owner_id here, by this we have to pass owner_id everytime we will update a track, we should validate owner.
  validates :owner_id, presence: true, on: :update

  ## FIXME_NISH Please verify if we need owner_name and reviewer_name or not.
  attr_accessor :owner_id, :owner_name, :reviewer_id, :reviewer_name

  strip_fields :name

  ## FIXME_NISH We don't need this scope.

  def self.extract(type, user)
    ## FIXME_NISH Please pass whole role name in it rather than a type. And After I think we don't need this method.
    role = "track_#{ type }".to_sym
    with_roles(role, user)
  end

  def add_track_role(role, user_id)
    ## FIXME_NISH Refactor this and also verify if user for the user_id is not present.
    if user_id.blank?
      add_error(:base, "can't be blank")
    else
      user = find_user(user_id)
      user.add_role(ROLES[role], self)
    end
  end

  def remove_track_role(role, user_id)
    ## FIXME_NISH Please add checks for user_id and user.
    find_user(user_id).remove_role(ROLES[role], self)
  end

  def assign_track_owner_role
    ## FIXME_NISH Please make this as a private method.
    user = find_user(owner_id) || company.owner
    user.add_role(ROLES[:track_owner], self)
  end

  def replace_owner(owner_id)
    remove_track_role(ROLES[:track_owner], owner.id)
    add_track_role(ROLES[:track_owner], owner_id)
  end

  private
    def add_error(field, error)
      ## TOOD_NISH we don't need this method, we should use errors.add
      errors[:base] = error
    end

    def find_user(user_id)
      company_users.find_by(id: user_id)
    end

    def company_users
      ## FIXME_NISH Remove this method and use delegate.
      company.users
    end
end
