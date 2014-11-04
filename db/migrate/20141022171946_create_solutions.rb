class CreateSolutions < ActiveRecord::Migration
  def change
    create_table :solutions do |t|

      t.string :link
      t.references :exercise_task
      t.timestamps
    end
  end
end
