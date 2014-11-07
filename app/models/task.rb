class Task < ActiveRecord::Base
  actable
  acts_as_nested_set
  include TheSortableTree::Scopes

  STATE = { in_progress: 'Started', submitted: 'Pending for review', completed: 'Completed'}

  belongs_to :track
  has_many :usertasks, dependent: :destroy
  has_many :users, through: :usertasks

  validates :title, :track, presence: true

  delegate :instructions, :is_hidden, :sample_solution, :reviewer_id, :reviewer, :reviewer_name, to: :specific, allow_nil: true

  def parent_title
    parent.try(:title)
  end

  def need_review
    specific ? 1 : 0
  end

  def move_to(target, position)
    raise ActiveRecord::ActiveRecordError, "You cannot change the parent of a task" if parent_id != target.parent_id
    super
  end
end
