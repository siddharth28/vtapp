class AddStateToUsertasks < ActiveRecord::Migration
  def change
    add_column :usertasks, :aasm_state, :string
  end
end
