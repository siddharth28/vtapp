class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :data
      t.references :usertask
      t.references :commenter
      t.timestamps
    end
  end
end
