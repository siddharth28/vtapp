class AddFieldsToUsertask < ActiveRecord::Migration
  def change
    add_column :usertasks, :reviewer_id, :integer
  end
end
