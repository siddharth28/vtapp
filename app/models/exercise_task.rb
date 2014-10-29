class ExerciseTask < ActiveRecord::Base
  acts_as :task

  has_attached_file :sample_solution

  has_many :solutions
  belongs_to :reviewer, class_name: User

  validates :reviewer, presence: true, if: :reviewer_id?
end
