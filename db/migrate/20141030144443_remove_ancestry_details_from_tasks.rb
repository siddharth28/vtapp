class RemoveAncestryDetailsFromTasks < ActiveRecord::Migration
  def change
    remove_column :tasks, :ancestry_depth, :integer, :default => 0
    remove_index :tasks, :ancestry
    remove_column :tasks, :ancestry, :string
  end
end
