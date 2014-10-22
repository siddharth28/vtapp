class ExerciseTask < ActiveRecord::Base
  include Task
  has_attached_file :sample_solution
  belongs_to :reveiwer, class_name: User
  has_many :solutions
end
