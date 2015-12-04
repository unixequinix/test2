class AddFeeToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :fee, :decimal, precision: 8, scale: 2
  end
end