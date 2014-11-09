class Usertask < ActiveRecord::Base
  include AASM

  STATE = { submitted: 'Task Submitted', resubmitted: 'Task Resubmitted', completed: 'Task completed' }

  belongs_to :user
  belongs_to :task

  has_many :urls, dependent: :destroy
  has_many :comments, dependent: :destroy

  after_create :add_start_time

  attr_accessor :url, :comment

  aasm do
    state :in_progress, initial: true
    state :submitted
    state :completed

    event :submit, after: :add_end_time do
      transitions from: :in_progress, to: :submitted, guard: :check_exercise?
      transitions from: :in_progress, to: :completed
    end

    event :accept do
      transitions from: :submitted, to: :completed, after: :task_completed
    end

    event :reject do
      transitions from: :submitted, to: :in_progress
    end
  end

  def submit_task(*args)
    task.specific ? submit_data(args[0]) : submit!
  end

  private
    def submit_comment(comment)
      comments.create(data: comment)
    end

    def submit_url(solution)
      urls.present? ? task_submitted(STATE[:resubmitted]) : task_submitted(STATE[:submitted])
      urls.find_or_create_by(name: solution)
    end

    def submit_data(*args)
      url = submit_url(args[0][:url]) if args[0][:url].present?
      submit_comment(args[0][:comment]) if args[0][:comment].present?
      submit! if (aasm_state != 'submitted' && url.present?)
    end

    def add_start_time
      self.start_time = Time.now
    end

    def add_end_time
      self.end_time = Time.now
    end

    def check_exercise?
      !!task.specific
    end

    def task_submitted(comment)
      submit_comment(comment)
    end

    def task_completed
      submit_comment(STATE[:completed])
    end
end
