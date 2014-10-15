class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.references :track
      t.references :user
      t.references :role
      t.timestamps
    end
  end
end
