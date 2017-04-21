class AddDefaultsToPaymentGateways < ActiveRecord::Migration[5.0]
  def change
    add_column :payment_gateways, :fee, :decimal, precision: 8, scale: 2, default: 0.0, null: false
    add_column :payment_gateways, :minimum, :decimal, precision: 8, scale: 2, default: 0.0, null: false

    PaymentGateway.all.each do |pg|
      pg.update(fee: pg[:data]["fee"]) if pg[:data]["fee"].present?
      pg.update minimum: pg[:data]["minimum"] if pg[:data]["minimum"].present?
      pg[:data].delete("fee")
      pg[:data].delete("minimum")
    end
  end
end
