class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.integer :parent_task_id
      t.string :description
      t.references :track
      t.actable
      t.timestamps
    end
  end
end
