class RemovePaymentServicesFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :payment_services, :integer
  end
end
