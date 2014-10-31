class ChangeTypeOfDataColumnInComments < ActiveRecord::Migration
  def change
    change_column :comments, :data, :text
  end
end
