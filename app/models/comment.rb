class Comment < ActiveRecord::Base
  belongs_to :usertask
  belongs_to :commenter, class_name: User

  ## FIXME_NISH Please look if we can use more appt. name than data.
  validates :usertask, :commenter, :data, presence: true

  def self.persisted
    select { |comment| comment.persisted? }
  end
end
