class Task < ActiveRecord::Base
  actable
  acts_as_nested_set
  include TheSortableTree::Scopes

  STATE = { not_started: 'Start', in_progress: 'Started', submitted: 'Pending for review', completed: 'Completed', restart: 'rejected kindly restart', resubmitted: 'Resubmitted for review'}

  belongs_to :track
  has_many :usertasks, dependent: :destroy
  has_many :users, through: :usertasks

  validates :track, presence: true

  ## FIXME_NISH Please break the validation into multiple validations because this will fire a query even if there is nil value for title.
  validates :title, presence: true, uniqueness: { scope: :track_id, case_sensitive: false }, length: { maximum: 255 }
  validate :cannot_be_own_parent, on: :update
  validate :parent_cannot_be_exercise_task

  scope :with_no_parent, -> { where(parent_id: nil) }
  ## FIXME_NISH Please use appt. name for this scope.
  scope :study_tasks, -> { where(actable_id: nil) }
  scope :with_track, ->(track) { where(track: track) }
  ## FIXME_NISH Please use appt. name for this scope.
  ## FIXME_NISH Please habe a look if we can do this with Arel Table.
  scope :visible_tasks, -> { joins("LEFT OUTER JOIN exercise_tasks ON exercise_tasks.id = tasks.actable_id").where("(tasks.actable_id IS NULL) OR (tasks.actable_id IS NOT NULL AND exercise_tasks.is_hidden = '0')") }

  strip_fields :title, :description

  delegate :is_hidden, :sample_solution, :instructions, :reviewer_id, :reviewer, :reviewer_name, to: :specific, allow_nil: true

  def parent_title
    ## FIXME_NISH make a delegate method to pluck title of the parent.
    parent.try(:title)
  end

  def need_review?
    ## FIXME_NISH Please make it as an alias.
    actable_id?
  end

  private
    def cannot_be_own_parent
      id.eql?(parent_id) && errors.add(:parent, 'cannot be its own parent')
    end

    def parent_cannot_be_exercise_task
      ## FIXME_NISH make a delegate method to pluck need_review? of the parent.
      parent.try(:need_review?) && errors.add(:parent, 'parent cannot be exercise task')
    end

    #callback awesome_nested_set
    def move_to(target, position)
      if target.class == Task && (parent_id != target.parent_id || position == :child)
        raise ActiveRecord::ActiveRecordError, "You cannot change the parent of a task"
      else
        super
      end
    end
end
