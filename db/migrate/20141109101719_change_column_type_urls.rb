class ChangeColumnTypeUrls < ActiveRecord::Migration
  def change
    change_column :urls, :name, :text
  end
end
