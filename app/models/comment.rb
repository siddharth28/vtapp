class Comment < ActiveRecord::Base
  belongs_to :task
  belongs_to :commenter, class_name: User
end
