class RemoveRefundServicesFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :refund_services, :integer
  end
end
