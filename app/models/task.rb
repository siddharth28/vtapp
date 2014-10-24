class Task < ActiveRecord::Base
  actable

  belongs_to :track
  belongs_to :parent_task, class_name: Task

  has_many :child_tasks, class_name: Task, foreign_key: :parent_task_id, dependent: :restrict_with_error
  has_many :comments

  attr_accessor :need_review

  validates :title, presence: true

  def parent_task_title
    parent_task.try(:title)
  end

  def need_review
    specific
  end
  [:instructions, :is_hidden, :sample_solution, :reviewer_id]
  def instructions
    specific.try(:instructions)
  end

  def is_hidden
    specific.try(:is_hidden)
  end

  def sample_solution
    specific.try(:sample_solution)
  end

  def reviewer_name
    specific.try(:reviewer).try(:name)
  end

  def reviewer_id
    specific.try(:reviewer)
  end
end
