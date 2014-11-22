class Usertask < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :task
  belongs_to :reviewer, class_name: 'User'


  has_many :urls, dependent: :destroy
  has_many :comments, dependent: :destroy


  before_create :assign_reviewer, if: -> { task.need_review? }
  attr_accessor :url, :comment

  aasm do
    state :not_started, initial: true
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

    event :accept do
      transitions from: :submitted, to: :completed
    end

    event :reject do
      transitions from: :submitted, to: :in_progress
    end
  end

  def submit_task(args)
    if task.need_review?
      arguments_present?(args) ? submit_data(args) : add_error_message
    else
      submit!
    end
  end

  private
    def submit_comment(comment)
      comments.create(data: comment, commenter: user)
    end

    def submit_url(solution)
      urls.find_or_create_by(name: solution)
      # FIXED
      # FIXME : I think this should be a callback in Url
    end

    def submit_data(args)
      if args[:url].present?
        submit_url(args[:url])
        submit! if (aasm_state != 'submitted')
      end
      if args[:comment].present?
        submit_comment(args[:comment])
      end
    end

    def add_start_time
      # FIXED
      # FIXME : Do not use Time.now, start using Time.current
      # self.start_time = Time.current
      update_attributes(start_time: Time.current)
    end

    def add_end_time
      # FIXED
      # FIXME : Do not use Time.now, start using Time.current
      update_attributes(end_time: Time.current)
    end

    def check_exercise?
      task.need_review?
    end

    def add_error_message
      errors[:base] = 'Either url or comment needs to be present for submission'
      false
    end

    def arguments_present?(args)
      args[:url].present? || args[:comment].present?
    end

    def assign_reviewer
      self.reviewer = task.reviewer
    end
end
