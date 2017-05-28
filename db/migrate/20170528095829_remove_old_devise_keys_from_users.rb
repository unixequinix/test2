class RemoveOldDeviseKeysFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :remember_created_at, :datetime
  end
end
