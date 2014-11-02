class Track < ActiveRecord::Base

  ROLES = { track_owner: :track_owner, track_reviewer: :track_reviewer, track_runner: :track_runner }

  resourcify

  belongs_to :company
  has_many :tasks

  attr_accessor :owner_id, :owner_name, :reviewer_id, :reviewer_name

  validates :name, uniqueness: { case_sensitive: false }, presence: true
  validates :references, presence: true
  validates :description, presence: true
  validates :instructions, presence: true

  after_create :assign_track_owner_role

  def owner
    company.users.with_role(:track_owner, self).first
  end

  def reviewer

    company.users.with_role(:track_reviewer, self)
  end

  def add_reviewer(user_id)
    user = find_user(user_id)
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
      if company.users.ids.include?(owner_id)
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
