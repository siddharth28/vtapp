class Track < ActiveRecord::Base

  ROLES = { track_owner: 'track_owner', track_reviewer: 'track_reviewer', track_runner: 'track_runner' }.with_indifferent_access

  resourcify

  belongs_to :company
  has_one :owner, through: :owner_role, source: :users
  ## FIXME_NISH Please use appt. name for the scope.
  has_one :owner_role, -> { track_with_role(Track::ROLES[:track_owner]) }, class_name: 'Role', foreign_key: :resource_id
  has_many :tasks, dependent: :destroy
  has_many :reviewer_role, -> { track_with_role(Track::ROLES[:track_reviewer])}, class_name: 'Role', foreign_key: :resource_id
  has_many :reviewers, through: :reviewer_role, source: :users

  after_create :assign_track_owner_role
  before_validation :replace_owner, on: :update

  validates :company, :references, :description, :instructions, :name, presence: true
  validates :name, uniqueness: { scope: :company_id, case_sensitive: false }, length: { maximum: 255 }, allow_blank: true

  validates :owner, presence: true, on: :update

  attr_accessor :owner_id, :reviewer_id

  strip_fields :name

  delegate :users, to: :company, prefix: :company

  ## FIXME_NISH Refactor add_track_role, remove_track_role and replace_owner.
  def add_track_role(role, user_id)
    (user = find_user(user_id)) ? user.add_role(ROLES[role], self) : errors.add(:base, "Please enter a valid User")
  end

  def remove_track_role(role, user_id)
    (user = find_user(user_id)) ? user.remove_role(ROLES[role], self) : errors.add(:base, "Please enter a valid User")
  end

  private
    def assign_track_owner_role
      user = find_user(owner_id) || company.owner
      user.add_role(ROLES[:track_owner], self)
    end

    def find_user(user_id)
      company_users.find_by(id: user_id)
    end

    def replace_owner
      if owner_id.blank? && !find_user(owner_id)
        errors.add(:base, "Please enter a valid User")
      else
        remove_track_role(ROLES[:track_owner], owner.id)
        add_track_role(ROLES[:track_owner], owner_id)
      end
    end
end
