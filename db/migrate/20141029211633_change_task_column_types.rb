class ChangeTaskColumnTypes < ActiveRecord::Migration
  def change
    change_column :tasks, :description, :text
    change_column :exercise_tasks, :instructions, :text
  end
end
