class AddActionIndexToStats < ActiveRecord::Migration[5.1]
  def change
    add_index :stats, :action
  end
end
