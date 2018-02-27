class RenameOldStatusToStatus < ActiveRecord::Migration[5.1]
  def change
    rename_column :orders, :old_status, :status
  end
end
