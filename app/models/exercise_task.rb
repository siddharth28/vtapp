class ExerciseTask < ActiveRecord::Base
  acts_as :task, dependent: :nullify

  has_attached_file :sample_solution

  belongs_to :reviewer, class_name: 'User'

  validates_attachment :sample_solution, content_type: { content_type: "application/zip" }, size: { in: 0..2.megabytes }, allow_blank: true
  validates :reviewer, presence: true
  validates :children, absence: { message: 'Cannot have children' }

  ## TODO Please confirm it with the manager.
  strip_fields :instructions

  def reviewer_name
    ## FIXME_NISH Use delegate.
    reviewer.name
  end
end
