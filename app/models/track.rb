class Track < ActiveRecord::Base
  belongs_to :company

  validates :name, uniqueness: { case_sensitive: false }, presence: true
  validates :references, presence: true
  validates :description, presence: true
  validates :instructions, presence: true

  attr_accessor :owner_name, :owner_email

  after_create :assign_track_owner_role

  def owner
    company.users.with_role(:track_owner, self)
  end

  private
    def assign_track_owner_role
      if owner_email
        company.users.find_by(email: owner_email).add_role(:track_owner, @track)
      else
        company.owner.first.add_role(:track_owner, @track)
      end
    end
end
