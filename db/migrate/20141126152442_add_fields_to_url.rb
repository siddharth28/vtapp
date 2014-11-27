class AddFieldsToUrl < ActiveRecord::Migration
  def change
    add_column(:urls, :submitted_at, :datetime)
  end
end
