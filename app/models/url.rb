class Url < ActiveRecord::Base
  belongs_to :usertask

  after_touch :add_submission_comment

  validates :usertask, presence: true
  validates :name, uniqueness: { scope: [:usertask_id], case_sensitive: false }, presence: true
  validates :name, format: URI::regexp(%w(http https))

  scope :persisted, -> { where.not(id: nil) }

  private
    def add_submission_comment
      usertask.urls.persisted.blank? ? add_first_submission_comment : add_resubmission_comment
    end

    def add_first_submission_comment
      usertask.comments.create(data: Task::STATE[:submitted], commenter: usertask.user)
    end

    def add_resubmission_comment
      usertask.comments.create(data: Task::STATE[:resubmitted], commenter: usertask.user)
    end

end
