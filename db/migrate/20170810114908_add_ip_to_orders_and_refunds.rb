class AddIpToOrdersAndRefunds < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :ip, :string
    add_column :refunds, :ip, :string
  end
end
