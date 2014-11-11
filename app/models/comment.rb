class Comment < ActiveRecord::Base
  belongs_to :usertask
  belongs_to :commenter, class_name: User

  # FIXED
  # FIXME : Revisit validations here
  validates :usertask, :commenter, :data, presence: true

end
