class AddEnumToPaymentGateways < ActiveRecord::Migration[5.0]
  def change
    add_column :payment_gateways, :name, :integer
    PaymentGateway.all.each do |gw|
      begin
        gw.update_attribute(:name, gw.gateway)
      rescue
      end
    end
    remove_column :payment_gateways, :gateway, :string
  end
end
