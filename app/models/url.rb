class Url < ActiveRecord::Base
  belongs_to :usertask

  after_create :add_submission_comment
  after_touch :add_resubmission_comment

  validates :usertask, presence: true
  validates :name, uniqueness: { scope: [:usertask_id], case_sensitive: false }, presence: true
  validates :name, format: URI::regexp(%w(http https))

  scope :persisted, -> { where.not(id: nil) }

  private
    def add_submission_comment
      comments = usertask.comments
      comment = comments.blank? ? comments.create(data: Task::STATE[:submitted], commenter: usertask.user) : add_resubmission_comment
    end

    def add_resubmission_comment
      comments.create(data: Task::STATE[:resubmitted], commenter: usertask.user)
    end

end
