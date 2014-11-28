class ExerciseTask < ActiveRecord::Base
  acts_as :task, dependent: :nullify

  has_attached_file :sample_solution

  belongs_to :reviewer, class_name: 'User'

  ## FIXED
  ## FIXME_NISH Add allow blank for this validation.
  ## FIXED
  ## FIXME_NISH Please add validation for size.
  validates_attachment :sample_solution, content_type: { content_type: "application/zip" }, size: { in: 0..2.megabytes }, allow_blank: true
  validates :reviewer, presence: true
  ## FIXED
  ## FIXME_NISH Please remove on: :update.
  validates :children, absence: { message: 'Cannot have children' }

  ## TODO Please confirm it with the manager.
  strip_fields :instructions

  def reviewer_name
    reviewer.name
  end
end
