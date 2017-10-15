class ChangePurchasePrecisions < ActiveRecord::Migration[5.1]
  def change
    change_column :stats, :monetary_unit_price, :decimal, precision: 10, scale: 2
    change_column :stats, :monetary_total_price, :decimal, precision: 10, scale: 2
  end
end
