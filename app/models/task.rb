class Task < ActiveRecord::Base
  actable
  acts_as_nested_set
  include TheSortableTree::Scopes

  belongs_to :track
  has_many :comments

  validates :title, presence: true
  validates :track, presence: true

  def parent_title
    parent.try(:title)
  end

  def need_review
    specific ? 1 : 0
  end

  [:instructions, :is_hidden, :sample_solution, :reviewer_id, :reviewer].each do |method|
    define_method(method) do
      specific.try(method)
    end
  end


  def reviewer_name
    specific.try(:reviewer).try(:name)
  end

end
