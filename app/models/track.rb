class Track < ActiveRecord::Base

  TRACK_ROLES = { track_owner: :track_owner, track_reviewer: :track_reviewer, track_runner: :track_runner }

  resourcify

  belongs_to :company

  after_create :assign_track_owner_role

  validates :name, uniqueness: { case_sensitive: false }, presence: true
  # FIXME : presence validations can ve clubbed in one
  validates :references, presence: true
  validates :description, presence: true
  validates :instructions, presence: true

  attr_accessor :owner_id, :owner_name, :reviewer_id, :reviewer_name

  strip_fields :name

  def owner
    company.users.with_role(:track_owner, self).first
  end

  # FIXME : method name should be plural as it returns activerelation
  def reviewer
    company.users.with_role(:track_reviewer, self)
  end

  def add_reviewer(user_id)
    user = find_user(user_id)
    # FIXME : dynamic track_runner? method can be used here
    # FIXME : No need to check for role here.
    unless user.has_role?(:track_runner, self)
      user.add_role(:track_reviewer, self)
    end
    user
  end

  def remove_reviewer(user_id)
    find_user(user_id).remove_role(:track_reviewer, self)
  end

  private
    def assign_track_owner_role
      # FIXME : This code can be simplified
      if company.users.ids.include?(owner_id.to_i)
        user = find_user(owner_id)
        user.add_role(:track_owner, self)
      else
        company.owner.first.add_role(:track_owner, self)
      end
    end

    def find_user(user_id)
      company.users.find_by(id: user_id)
    end
end
