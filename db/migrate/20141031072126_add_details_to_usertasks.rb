class AddDetailsToUsertasks < ActiveRecord::Migration
  def change
    add_column :usertasks, :start_time, :datetime
    add_column :usertasks, :end_time, :datetime
  end
end
