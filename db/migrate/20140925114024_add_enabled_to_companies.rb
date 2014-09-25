class AddEnabledToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :enabled, :boolean, default: true
  end
end
