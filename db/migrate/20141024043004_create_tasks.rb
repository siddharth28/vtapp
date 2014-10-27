class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.integer :parent_id
      t.string :description
      t.references :track
      t.integer :lft
      t.integer :rgt
      t.references :taskable, polymorphic: true
      t.timestamps
    end
  end
end
