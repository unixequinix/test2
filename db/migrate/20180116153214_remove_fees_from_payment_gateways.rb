class RemoveFeesFromPaymentGateways < ActiveRecord::Migration[5.1]
  def change
    remove_column :payment_gateways, :fee, :decimal, precision: 8, scale: 2, default: "0.0", null: false
  end
end
