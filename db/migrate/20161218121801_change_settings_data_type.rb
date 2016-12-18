class ChangeSettingsDataType < ActiveRecord::Migration
  def change
    change_column :events, :registration_settings, :jsonb, null: false, default: '{}'
    change_column :events, :gtag_settings, :jsonb, null: false, default: '{}'
    change_column :events, :device_settings, :jsonb, null: false, default: '{}'

    Order.update_all(payment_data: {})
    PaymentGateway.update_all(data: {})

    change_column :orders, :payment_data, :jsonb, null: false, default: '{}'
    change_column :payment_gateways, :data, :jsonb, null: false, default: '{}'
  end
end
