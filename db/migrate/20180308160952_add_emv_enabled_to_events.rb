class AddEmvEnabledToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :emv_enabled, :boolean, default: false
  end
end
