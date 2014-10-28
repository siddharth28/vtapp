class Usertask < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :task

  has_many :urls, dependent: :destroy
  has_many :comments, dependent: :destroy

  attr_accessor :url, :comment

  aasm do
    state :in_progress, initial: true
    state :submitted
    state :completed

    event :submit do
      transitions in_progress: :submitted
    end

    event :accepted do
      transitions submitted: :completed
    end

    event :rejected do
      transitions submitted: :in_progress
    end
  end
end
