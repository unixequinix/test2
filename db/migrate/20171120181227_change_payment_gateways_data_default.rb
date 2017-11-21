class ChangePaymentGatewaysDataDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :payment_gateways, :data, {}
  end
end
