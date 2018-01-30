class RemoveOldStatusFromRefunds < ActiveRecord::Migration[5.1]
  def change
    remove_column :refunds, :status, :string
  end
end
