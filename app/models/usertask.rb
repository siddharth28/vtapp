class Usertask < ActiveRecord::Base
  include AASM

  validates :user, :task, presence: true

  belongs_to :user
  belongs_to :task
  belongs_to :reviewer, class_name: 'User'

  has_many :urls, dependent: :destroy
  has_many :comments, dependent: :destroy

  ## FIXME_NISH delegate need_review to task.
  before_create :assign_reviewer if :need_review?

  attr_accessor :comment

  delegate :need_review?, to: :task
  alias_method :check_exercise?, :need_review?

  aasm do
    state :not_started, initial: true
    state :restart
    state :in_progress
    state :submitted
    state :completed

    event :start, after: [:add_start_time, :mark_parent_task_started] do
      transitions from: :not_started, to: :in_progress
    end

    event :submit, after: [:add_end_time, :mark_parent_task_finished] do
      transitions from: :in_progress, to: :submitted, guard: :check_exercise?
      transitions from: :in_progress, to: :completed
    end

    event :accept, after: [:send_notification_email, :mark_parent_task_finished] do
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
      update_column(:start_time, Time.current)
    end

    def add_end_time
      # FIXED
      # Not fixed
      # FIXED
      # FIXME : Do not use Time.now, start using Time.current
      update_column(:end_time, Time.current)
    end

    def assign_reviewer
      self.reviewer = task.reviewer
    end

    def send_notification_email
      UsertaskMailer.delay.exercise_review_email(self)
    end

    def mark_parent_task_finished
      ## FIXED
      ## FIXME_NISH we can add a check of parent_usertaks rather than using try.
      if parent_task
        children_submitted = parent_task.children.all? { |task| task.usertasks.find_by(user: user).completed? }
        parent_usertask.try(:submit!) if parent_usertask && children_submitted && parent_usertask.in_progress?
      end
    end

    def mark_parent_task_started
      ## FIXED
      ## FIXME_NISH we can add a check of parent_usertaks rather than using try.
      parent_task && parent_usertask && parent_usertask.not_started? && parent_usertask.start!
    end

    def parent_task
      task.parent
    end

    def parent_usertask
      parent_task.usertasks.find_by(user: user)
    end
end
