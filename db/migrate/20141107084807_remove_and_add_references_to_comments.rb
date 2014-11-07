  class RemoveAndAddReferencesToComments < ActiveRecord::Migration
  def change
    remove_reference :comments, :task
    add_reference :comments, :usertask, index: true
  end
end
