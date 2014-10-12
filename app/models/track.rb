class Track < ActiveRecord::Base

  belongs_to :company
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :references, presence: true
  validates :description, presence: true
  validates :instructions, presence: true
  validates :track_owner, presence: true

end
