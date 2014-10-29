class ExerciseTask < ActiveRecord::Base
  acts_as :task, dependent: :nullify

  has_attached_file :sample_solution
  belongs_to :reviewer, class_name: User
  has_many :solutions

  validates_attachment :sample_solution, content_type: { content_type: "application/zip" }
  validates :reviewer, presence: true
end
