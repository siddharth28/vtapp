module Task

  def self.included(base)
    base.class_eval do
      has_many :child_tasks, class_name: base.name, foreign_key: :parent_tak_id, dependent: :restrict_with_error
      has_many :comments
      belongs_to :parent_tak, class_name: base.name
      belongs_to :track
    end
  end

end