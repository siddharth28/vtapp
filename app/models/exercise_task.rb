class ExerciseTask < ActiveRecord::Base
  acts_as :task, dependent: :nullify

  has_attached_file :sample_solution

  belongs_to :reviewer, class_name: 'User'

  validates_attachment :sample_solution, content_type: { content_type: "application/zip" }
  validates :reviewer, presence: true
  validates :children, absence: { message: 'Cannot have children' }, on: :update

  strip_fields :instructions

  def reviewer_name
    reviewer.name
  end
end
