class Task < ActiveRecord::Base

  actable
  acts_as_tree cache_depth: true

  has_many :child_tasks, class_name: Task, foreign_key: :parent_id, dependent: :restrict_with_error
  has_many :comments
  belongs_to :parent_task, class_name: Task
  belongs_to :track

  attr_accessor :need_review

  state_machine :state, initial: :not_started_yet do
    event :start do
      transition :not_started_yet => :in_progress
    end

    event :submit do
      transition :in_progress => :submitted
    end

    event :accepted do
      transition :submitted => :completed
    end

    event :rejected do
      transition :submitted => :in_progress
    end
  end

  def parent_task_title
    parent_task.try(:title)
  end

  def need_review
    specific
  end

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
    specific.try(:reviewer_id)
  end
end
