class Task < ActiveRecord::Base
  actable
  belongs_to :track
  has_many :child_tasks, class_name: Task, foreign_key: :parent_task_id, dependent: :restrict_with_error
  has_many :comments
  belongs_to :parent_task, class_name: Task
end
