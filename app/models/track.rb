class Track < ActiveRecord::Base
  belongs_to :company
  validates :name, presence: true, uniqueness: { case_sensitive: false }, allow_blank: true
  validates :references, presence: true
  validates :description, presence: true
  validates :instructions, presence: true

  attr_accessor :track_owner

  after_create :assign_track_owner_role

  private
    def assign_track_owner_role
      if track_owner
        company.users.find(track_owner.split(':')[1]).add_role(:track_owner, @track)
      else
        company.users.find(company.owner.first).add_role(:track_owner, @track)
      end
    end
end
