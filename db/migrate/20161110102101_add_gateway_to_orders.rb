class AddGatewayToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :gateway, :string
  end
end
