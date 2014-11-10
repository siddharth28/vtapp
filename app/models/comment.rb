class Comment < ActiveRecord::Base
  belongs_to :usertask
  belongs_to :commenter, class_name: User

  validates :data, presence: true

  # FIXME : Revisit validations here
end
