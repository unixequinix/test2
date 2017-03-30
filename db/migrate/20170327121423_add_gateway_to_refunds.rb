class AddGatewayToRefunds < ActiveRecord::Migration[5.0]
  def change
    add_column :refunds, :gateway, :string
    Refund.update_all(gateway: "bank_account")
  end
end
