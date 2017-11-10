class AddExtraFieldsToPaymentGateways < ActiveRecord::Migration[5.1]
  def change
    add_column :payment_gateways, :extra_fields, :text, array: true, default: []
  end
end
