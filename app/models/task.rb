class Task < ActiveRecord::Base
  actable
  acts_as_nested_set
  include TheSortableTree::Scopes

  STATE = { in_progress: 'Started', submitted: 'Pending for review', completed: 'Completed'}

  belongs_to :track
  has_many :usertasks, dependent: :destroy
  has_many :users, through: :usertasks

  validates :title, :track, presence: true

  [:instructions, :is_hidden, :sample_solution, :reviewer_id, :reviewer].each do |method|
    define_method(method) do
      specific.try(method)
    end
  end

  def parent_title
    parent.try(:title)
  end

  def need_review
    specific ? 1 : 0
  end

  def reviewer_name
    specific.try(:reviewer).try(:name)
  end

  def reviewer_id
    specific.try(:reviewer_id)
  end
end
