class ExerciseTask < ActiveRecord::Base
  acts_as :task

  has_attached_file :sample_solution
  belongs_to :reveiwer, class_name: User
  has_many :solutions

  validates :reviewer, presence: true, if: :reviewer_id?
end
