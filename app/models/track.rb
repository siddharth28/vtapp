class Track < ActiveRecord::Base
  has_many :links
  has_many :users, through: :links
  belongs_to :company

  validates :name, uniqueness: { case_sensitive: false }, presence: true
  validates :references, presence: true
  validates :description, presence: true
  validates :instructions, presence: true

  attr_accessor :owner_id

  after_create :assign_track_owner_role

  def owner
    users.with_role(:track_owner).first
  end

  def reviewer
    users.with_role(:track_reviewer)
  end

  private
    def assign_track_owner_role
      if users.include?(owner_id)
        create_link(user_id, :track_owner)
      else
        create_link(company.owner, :track_owner)
      end
    end

    def create_link(user, role)
      role = Role.find_by(name: role)
      links.create(user_id: user.id, role_id: role.id)
    end
end
