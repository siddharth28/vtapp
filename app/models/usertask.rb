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

  attr_accessor :comment, :task_status

  delegate :need_review?, to: :task

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
      transitions from: :in_progress, to: :submitted, guard: :need_review?
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

  def review_exercise
    if submitted?
      if task_status == 'accept'
        accept! && comments.create(data: comment + 'Your exercise is accepted', commenter: reviewer)
      elsif task_status == 'reject'
        reject! && comments.create(data: comment + 'Your exercise is rejected', commenter: reviewer)
      end
    end
  end

  private
    def add_start_time
      touch(:start_time)
    end

    def add_end_time
      touch(:end_time)
    end

    def assign_reviewer
      self.reviewer = task.reviewer
    end

    def send_notification_email
      UsertaskMailer.delay.exercise_review_email(self)
    end

    def mark_parent_task_finished
      ## FIXME_NISH we can add a check of parent_usertaks rather than using try.
      ## FIXME_NISH move checking of all children completed to a new method and refector this one.
      if parent_task
        children_submitted = parent_task.children.all? { |task| task.usertasks.find_by(user: user).completed? }
        parent_usertask.try(:submit!) if parent_usertask && children_submitted && parent_usertask.in_progress?
      end
    end

    def mark_parent_task_started
      parent_task && parent_usertask && parent_usertask.not_started? && parent_usertask.start!
    end

    def parent_task
      task.parent
    end

    def parent_usertask
      parent_task.usertasks.find_by(user: user)
    end
end
