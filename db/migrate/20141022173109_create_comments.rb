class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :data
      t.references :task
      t.references :commenter
      t.timestamps
    end
  end
end
