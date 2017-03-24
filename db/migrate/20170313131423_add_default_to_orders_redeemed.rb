class AddDefaultToOrdersRedeemed < ActiveRecord::Migration[5.0]
  def change
    change_column_default :order_items, :redeemed, false
  end
end
