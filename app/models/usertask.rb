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

  def submit_comment(comment)
    comments.create(data: comment)
  end

  def submit_url(solution)
    urls.find_or_create_by(name: solution)
  end

  def submit_data(*args)
    url = submit_url(args[0][:url]) unless(arg[0][url].blank?)
    submit_comment(arg[0][comment]) unless(arg[0][comment].blank?)
    submit! unless(aasm_state == 'submitted' || arg[0][url].blank?)
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
