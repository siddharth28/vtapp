class CreateStudyTasks < ActiveRecord::Migration
  def change
    create_table :study_tasks do |t|

      t.string :title
      t.integer :parent_task_id
      t.string :description
      t.references :track

      t.timestamps
    end
  end
end
