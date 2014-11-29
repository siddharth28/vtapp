class Track < ActiveRecord::Base

  ROLES = { track_owner: 'track_owner', track_reviewer: 'track_reviewer', track_runner: 'track_runner' }.with_indifferent_access

  resourcify

  belongs_to :company
  has_one :owner, through: :owner_role, source: :users
  # FIXED
  ## FIXME_NISH Please create a scope for this and reuse it in reviewer_role.
  has_one :owner_role, -> { track_with_role(Track::ROLES[:track_owner]) }, class_name: 'Role', foreign_key: :resource_id
  has_many :tasks, dependent: :destroy
  has_many :reviewer_role, -> { track_with_role(Track::ROLES[:track_reviewer])}, class_name: 'Role', foreign_key: :resource_id
  has_many :reviewers, through: :reviewer_role, source: :users

  after_create :assign_track_owner_role
  before_validation :replace_owner, on: :update

  validates :company, :references, :description, :instructions, presence: true
  # FIXED
  ## FIXME_NISH Please break the validation into multiple validations because this will fire a query even if there is nil value for title.
  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }
  validates :name, presence: true, length: { maximum: 255 }

  # FIXED
  ## FIXME_NISH We should not validate owner_id here, by this we have to pass owner_id everytime we will update a track, we should validate owner.
  validates :owner, presence: true, on: :update

  # FIXED
  ## FIXME_NISH Please verify if we need owner_name and reviewer_name or not.
  attr_accessor :owner_id, :reviewer_id

  strip_fields :name

  delegate :users, to: :company, prefix: :company

  # FIXED
  ## FIXME_NISH We don't need this scope.

  # FIXED
  ## FIXME_NISH Please pass whole role name in it rather than a type. And After I think we don't need this method.

  # FIXED
  ## FIXME_NISH Refactor this and also verify if user for the user_id is not present.
  def add_track_role(role, user_id)
    (user = find_user(user_id)) ? user.add_role(ROLES[role], self) : errors.add(:base, "Please enter a valid User")
  end

  # FIXED
  ## FIXME_NISH Please add checks for user_id and user.
  def remove_track_role(role, user_id)
    (user = find_user(user_id)) ? user.remove_role(ROLES[role], self) : errors.add(:base, "Please enter a valid User")
  end

  private
    # FIXED
    ## FIXME_NISH Please make this as a private method.
    def assign_track_owner_role
      user = find_user(owner_id) || company.owner
      user.add_role(ROLES[:track_owner], self)
    end

    # FIXED
    ## TOOD_NISH we don't need this method, we should use errors.add

    def find_user(user_id)
      company_users.find_by(id: user_id)
    end

    # FIXED
    ## FIXME_NISH Remove this method and use delegate.

    def replace_owner
      if owner_id.blank? && !find_user(owner_id)
        errors.add(:base, "Please enter a valid User")
      else
        remove_track_role(ROLES[:track_owner], owner.id)
        add_track_role(ROLES[:track_owner], owner_id)
      end
    end
end
