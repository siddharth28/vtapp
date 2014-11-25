class Task < ActiveRecord::Base
  actable
  acts_as_nested_set
  include TheSortableTree::Scopes

  STATE = { not_started: 'Start', in_progress: 'Started', submitted: 'Pending for review', completed: 'Completed', restart: 'rejected kindly restart', resubmitted: 'Resubmitted for review'}

  belongs_to :track
  has_many :usertasks, dependent: :destroy
  has_many :users, through: :usertasks

  validates :track, presence: true
  validates :title, presence: true, uniqueness: { scope: :track_id, case_sensitive: false }, length: { maximum: 255 }
  validate :cannot_be_own_parent, on: :update

  scope :with_no_parent, -> { where(parent_id: nil) }
  scope :with_track, ->(track) { where(track: track) }
  scope :visible_tasks, -> { joins("LEFT OUTER JOIN exercise_tasks ON exercise_tasks.id = tasks.actable_id").where("(tasks.actable_id IS NULL) OR (tasks.actable_id IS NOT NULL AND exercise_tasks.is_hidden = '0')") }

  strip_fields :title, :description

  delegate :is_hidden, :sample_solution, :instructions, :reviewer_id, :reviewer, :reviewer_name, to: :specific, allow_nil: true

  def parent_title
    parent.try(:title)
  end

  def need_review?
    actable_id?
  end

  private
    def cannot_be_own_parent
      errors.add(:parent, 'cannot be its own parent') if id == parent_id
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
