class Url < ActiveRecord::Base
  belongs_to :usertask

  after_create :add_submission_comment

  # FIXED
  # FIXME : Should also validate presence of usertask
  validates :usertask, presence: true
  validates :name, uniqueness: { scope: [:usertask_id], case_sensitive: false }, presence: true

  def add_submission_comment
    comments = usertask.comments
    comment = comments.blank? ? comments.create(data: Usertask::STATE[:submitted]) : comments.create(data: Usertask::STATE[:resubmitted])
  end

end
