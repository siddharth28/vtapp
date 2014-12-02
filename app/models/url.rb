class Url < ActiveRecord::Base
  URL_FORMAT = URI::regexp(%w(http https))

  belongs_to :usertask

  validates :usertask, presence: true
  validates :name, presence: true
  validates :name, uniqueness: { scope: :usertask_id, case_sensitive: false }, format: { with: URL_FORMAT }, allow_blank: true

  ## FIXED
  ## FIXME_NISH Remove this scope and if you require this functionality create a class method for this.
  def self.persisted
    select { |url| url.persisted? }
  end

  def add_submission_comment
    ## FIXED
    ## FIXME_NISH Use touch here.
    touch(:submitted_at)
    ## FIXED
    ## FIXME_NISH Fetch the logic below in another method and use it instead of state.
    usertask.comments.create(data: Task::STATE[state], commenter: usertask.user)
  end

  private
    def state
      usertask.urls.persisted.blank? ? :submitted : :resubmitted
    end
end
