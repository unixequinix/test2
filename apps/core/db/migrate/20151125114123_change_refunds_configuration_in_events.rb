class ChangeRefundsConfigurationInEvents < ActiveRecord::Migration
  def change
    remove_column :events, :refund_service
    add_column :events, :refund_services, :integer, null: false, default: 0
  end
end
