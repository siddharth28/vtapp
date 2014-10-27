class Task < ActiveRecord::Base
  # actable
  # acts_as_nested_set
  # include TheSortableTree::Scopes

  # belongs_to :track
  # belongs_to :parent, class_name: Task

  # has_many :child_tasks, class_name: Task, foreign_key: :parent_id, dependent: :restrict_with_error
  # has_many :comments

  # attr_accessor :need_review

  # validates :title, presence: true

  # def parent_title
  #   parent.try(:title)
  # end

  # def need_review
  #   specific ? 1 : 0
  # end
  # [:instructions, :is_hidden, :sample_solution, :reviewer_id].each do |method|
  #   define_method(method) do
  #     specific.try(method)
  #   end
  # end


  # def reviewer_name
  #   specific.try(:reviewer).try(:name)
  # end

  belongs_to :taskable, polymorphic: true

end
