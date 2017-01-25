class ChangeSettingsDataType < ActiveRecord::Migration
  def change
    change_column(:events, :registration_settings, :jsonb, null: false, default: '{}') if column_exists?(:events, :registration_settings)
    change_column(:events, :gtag_settings, :jsonb, null: false, default: '{}') if column_exists?(:events, :gtag_settings)
    change_column(:events, :device_settings, :jsonb, null: false, default: '{}') if column_exists?(:events, :device_settings)

    Order.update_all(payment_data: {})
    PaymentGateway.update_all(data: {})

    change_column :orders, :payment_data, :jsonb, null: false, default: '{}'
    change_column :payment_gateways, :data, :jsonb, null: false, default: '{}'
  end
end
