class Comment < ActiveRecord::Base
  belongs_to :usertask
  belongs_to :commenter, class_name: User

  ## FIXME_NISH Please look if we can use more appt. name than data.
  validates :usertask, :commenter, :data, presence: true

  ## FIXME_NISH This scope is not appt. Please create a class method to find the persisted object from an array of abjects.
  scope :persisted, -> { where.not(id: nil) }
end
