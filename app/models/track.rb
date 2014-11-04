class Track < ActiveRecord::Base

  ROLES = { track_owner: :track_owner, track_reviewer: :track_reviewer, track_runner: :track_runner }

  resourcify

  belongs_to :company
  has_many :tasks, dependent: :destroy

  after_create :assign_track_owner_role

  validates :name, uniqueness: { case_sensitive: false }, presence: true
  # FIXED
  # FIXME : presence validations can ve clubbed in one
  validates :references, :description, :instructions, presence: true

  attr_accessor :owner_id, :owner_name, :reviewer_id, :reviewer_name

  strip_fields :name

  def self.extract(type, user)
    role = "track_#{ type }".to_sym
    with_roles(role, user)
  end

  def owner
    company_users.with_role(ROLES[:track_owner], self).first
  end
  # FIXED
  # FIXME : method name should be plural as it returns activerelation
  def reviewers
    company_users.with_role(ROLES[:track_reviewer], self)
  end

  def add_reviewer(user_id)
    user = find_user(user_id)
    # FIXME : dynamic track_runner? method can be used here
    # FIXME : No need to check for role here.
    user.add_role(ROLES[:track_reviewer], self)
  end

  def remove_reviewer(user_id)
    find_user(user_id).remove_role(ROLES[:track_reviewer], self)
  end

  private
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

    def find_user(user_id)
      company_users.find_by(id: user_id)
    end

    def company_users
      company.users
    end
end
