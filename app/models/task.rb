class Task < ActiveRecord::Base
  actable
  belongs_to :track
  has_many :child_tasks, class_name: Task, foreign_key: :parent_task_id, dependent: :restrict_with_error
  has_many :comments
  belongs_to :parent_task, class_name: Task


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

  def reveiwer_name
    specific.try(:reveiwer).try(:name)
  end

  def reveiwer_id
    specific.try(:reveiwer_id)
  end
end
