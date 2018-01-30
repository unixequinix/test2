class RenameOldStatusToStatusInRefunds < ActiveRecord::Migration[5.1]
  def change
    rename_column :refunds, :old_status, :status
  end
end
