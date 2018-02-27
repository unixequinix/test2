class DropPaymentGateways < ActiveRecord::Migration[5.1]
  def change
    drop_table :payment_gateways
  end
end
