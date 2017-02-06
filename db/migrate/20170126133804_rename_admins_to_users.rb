class RenameAdminsToUsers < ActiveRecord::Migration[5.0]
  def change
    drop_table :users if data_source_exists?(:users)
    rename_table :admins, :users
  end
end
