class CreateUsertasks < ActiveRecord::Migration
  def change
    create_table :usertasks do |t|
      t.belongs_to :task
      t.belongs_to :user
      t.timestamps
    end
  end
end
