class Url < ActiveRecord::Base
  belongs_to :usertask

  validates :usertask, presence: true

  ## FIXME_NISH Please divide the validations, use allow_blank, and remove array with usertask_id.
  validates :name, uniqueness: { scope: [:usertask_id], case_sensitive: false }, presence: true

  ## FIXME_NISH Move URI::regexp(%w(http https)) in a constant.
  validates :name, format: URI::regexp(%w(http https))

  ## FIXME_NISH Remove this scope and if you require this functionality create a class method for this.
  scope :persisted, -> { where.not(id: nil) }

  def add_submission_comment
    ## FIXME_NISH Use touch here.
    update_column(:submitted_at, Time.current)
    ## FIXME_NISH Fetch the logic below in another method and use it instead of state.
    state = usertask.urls.persisted.blank? ? :submitted : :resubmitted
    usertask.comments.create(data: Task::STATE[state], commenter: usertask.user)
  end
end
