class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :name
      t.string :description
      t.string :instructions
      t.string :references
      t.boolean :enabled
      t.references :company
      t.timestamps
    end
  end
end
