class Task < ActiveRecord::Base

  actable
  acts_as_tree cache_depth: true

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
    specific ? 1 : 0
  end
  [:instructions, :is_hidden, :sample_solution, :reviewer_id].each do |method|
    define_method(method) do
      specific.try(method)
    end
  end


  def reviewer_name
    specific.try(:reviewer).try(:name)
  end

  def reviewer_name
    specific.try(:reviewer).try(:name)
  end

  def reviewer_id
    specific.try(:reviewer_id)
  end
end
