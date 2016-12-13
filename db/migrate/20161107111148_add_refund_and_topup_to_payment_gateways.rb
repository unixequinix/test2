class AddRefundAndTopupToPaymentGateways < ActiveRecord::Migration
  def change
    add_column :payment_gateways, :refund, :boolean
    add_column :payment_gateways, :topup, :boolean
  end
end
