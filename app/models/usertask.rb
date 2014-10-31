class Usertask < ActiveRecord::Base
  include AASM

  TASK_STATES = { in_progress: 'Started', submitted: 'Pending for review', completed: 'Completed' }

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

  def submit_task(*args)
    task.specific ? submit_data(args[0][:url], args[0][:comment]) : task_submit!
  end

  def submit_data(url, comment)
    urls.find_or_create_by(name: url)
    comments.create(data: comment)
    exercise_submit! unless(aasm_state == 'submitted')
  end
end
