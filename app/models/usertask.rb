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
      transitions from: :in_progress, to: :submitted
    end

    event :accept do
      transitions from: :submitted, to: :completed
    end

    event :reject do
      transitions from: :submitted, to: :in_progress
    end
  end

  def submit_data(url, comment)
    urls.find_or_create_by(name: url)
    comments.find_or_create_by(data: comment)
    submit! unless(aasm_state == 'submitted')
  end
end
