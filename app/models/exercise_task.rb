class ExerciseTask < ActiveRecord::Base
  # acts_as :task

  has_attached_file :sample_solution
  belongs_to :reviewer, class_name: User
  has_many :solutions

  has_one :task, as: :taskable

  validates :reviewer, presence: true, if: :reviewer_id?
end
