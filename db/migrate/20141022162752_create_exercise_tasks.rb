class CreateExerciseTasks < ActiveRecord::Migration
  def change
    create_table :exercise_tasks do |t|
      t.string :title
      t.integer :parent_task_id
      t.string :description
      t.boolean :need_review
      t.references :track
      t.string :instructions
      t.attachment :sample_solution
      t.integer :reveiwer_id
      t.boolean :is_hidden
      t.timestamps
    end
  end
end
