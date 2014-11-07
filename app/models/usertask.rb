class Usertask < ActiveRecord::Base
  include AASM

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
      transitions from: :submitted, to: :completed
    end

    event :reject do
      transitions from: :submitted, to: :in_progress
    end
  end

  def submit_task(*args)
    task.specific ? submit_data(args[0]) : submit!
  end

  def submit_data(*args)
    urls.find_or_create_by(name: args[0][:url])
    comments.create(data: args[0][:comment])
    submit! unless(aasm_state == 'submitted')
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
end
