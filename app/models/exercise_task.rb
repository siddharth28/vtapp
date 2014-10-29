class ExerciseTask < ActiveRecord::Base
  acts_as :task, dependent: :nullify

  has_attached_file :sample_solution
  belongs_to :reviewer, class_name: User
  has_many :solutions

  validates_attachment_file_name :sample_solution, :matches => [/zip\Z/, /rar\Z/]

  validates :reviewer, presence: true, if: :reviewer_id?
end
