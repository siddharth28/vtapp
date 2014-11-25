class AddTimestampsUrl < ActiveRecord::Migration
  def change
    add_column(:urls, :created_at, :datetime)
    add_column(:urls, :updated_at, :datetime)
  end
end
