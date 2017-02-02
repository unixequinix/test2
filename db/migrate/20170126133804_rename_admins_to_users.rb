class RenameAdminsToUsers < ActiveRecord::Migration[5.0]
  def change
    rename_table :admins, :users unless data_source_exists?(:users)
  end
end
