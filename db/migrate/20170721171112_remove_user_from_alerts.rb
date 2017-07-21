class RemoveUserFromAlerts < ActiveRecord::Migration[5.1]
  def change
    remove_column :alerts, :user_id, :integer
  end
end
