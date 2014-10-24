class CreateExerciseTasks < ActiveRecord::Migration
  def change
    create_table :exercise_tasks do |t|
      t.string :instructions
      t.attachment :sample_solution
      t.integer :reviewer_id
      t.boolean :is_hidden
      t.timestamps
    end
  end
end
