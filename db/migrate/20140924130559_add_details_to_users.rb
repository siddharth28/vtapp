class AddDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :department, :string
    add_column :users, :enabled, :boolean, default: true
    add_column :users, :mentor_id, :integer
  end
end
