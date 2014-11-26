class Usertask < ActiveRecord::Base
  include AASM

  validates :user, :task, presence: true

  belongs_to :user
  belongs_to :task
  belongs_to :reviewer, class_name: 'User'


  has_many :urls, dependent: :destroy
  has_many :comments, dependent: :destroy


  before_create :assign_reviewer, if: -> { task.need_review? }
  attr_accessor :url, :comment

  aasm do
    state :not_started, initial: true
    state :restart
    state :in_progress
    state :submitted
    state :completed

    event :start, after: :add_start_time do
      transitions from: :not_started, to: :in_progress
    end

    event :submit, after: :add_end_time do
      transitions from: :in_progress, to: :submitted, guard: :check_exercise?
      transitions from: :in_progress, to: :completed
    end

    event :accept, after: :send_notification_email do
      transitions from: :submitted, to: :completed
    end

    event :reject, after: :send_notification_email do
      transitions from: :submitted, to: :restart
    end

    event :restart do
      transitions from: :restart, to: :in_progress
    end
  end

  [:not_started, :in_progress, :submitted, :completed, :restart].each do |state|
    define_method "#{ state }?" do
      aasm_state == state.to_s
    end
  end


  private
    def add_start_time
      # FIXED
      # FIXME : Do not use Time.now, start using Time.current
      # self.start_time = Time.current
      update_attributes(start_time: Time.current)
    end

    def add_end_time
      # Not fixed
      # FIXED
      # FIXME : Do not use Time.now, start using Time.current
      update_attributes(end_time: Time.current)
    end

    def check_exercise?
      task.need_review?
    end

    def add_error_message
      # FIXME : Not a right way to add errors
      errors[:base] << 'Either url or comment needs to be present for submission'
      false
    end

    def assign_reviewer
      self.reviewer = task.reviewer
    end

    def send_notification_email
      UserMailer.delay.exercise_review_email(self)
    end
end
