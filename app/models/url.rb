class Url < ActiveRecord::Base
  belongs_to :usertask

  validates :usertask, presence: true
  validates :name, uniqueness: { scope: [:usertask_id], case_sensitive: false }, presence: true
  validates :name, format: URI::regexp(%w(http https))

  scope :persisted, -> { where.not(id: nil) }

  def add_submission_comment
    update_column(:submitted_at, Time.current)
    state = usertask.urls.persisted.blank? ? :submitted : :resubmitted
    usertask.comments.create(data: Task::STATE[state], commenter: usertask.user)
  end
end
