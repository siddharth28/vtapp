class Comment < ActiveRecord::Base
  belongs_to :usertask
  belongs_to :commenter, class_name: User

  validates :usertask, :commenter, :data, presence: true
end
