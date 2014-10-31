class Usertask < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :task

  has_many :urls, dependent: :destroy
  has_many :comments, dependent: :destroy

  attr_accessor :url, :comment

  aasm do
    state :in_progress, initial: true
    state :submitted
    state :completed

    event :exercise_submit do
      transitions from: :in_progress, to: :submitted
    end

    event :accept do
      transitions from: :submitted, to: :completed
    end

    event :reject do
      transitions from: :submitted, to: :in_progress
    end

    event :task_submit do
      transitions from: :in_progress, to: :completed
    end
  end

  def submit_task
    task.specific ? exercise_submit! : task_submit!
  end
end
