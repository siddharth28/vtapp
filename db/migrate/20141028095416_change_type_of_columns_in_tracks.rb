class ChangeTypeOfColumnsInTracks < ActiveRecord::Migration
  def change
    change_column :tracks, :description, :text
    change_column :tracks, :instructions, :text
    change_column :tracks, :references, :text
  end
end
