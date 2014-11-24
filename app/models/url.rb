class Url < ActiveRecord::Base
  belongs_to :usertask

  after_create :add_submission_comment

  validates :usertask, presence: true
  validates :name, uniqueness: { scope: [:usertask_id], case_sensitive: false }, presence: true

  private
    def add_submission_comment
      comments = usertask.comments
      comment = comments.blank? ? comments.create(data: Usertask::STATE[:submitted], commenter: usertask.user) : comments.create(data: Usertask::STATE[:resubmitted], commenter: usertask.user)
    end

end
