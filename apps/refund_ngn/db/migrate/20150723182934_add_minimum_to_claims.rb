class AddMinimumToClaims < ActiveRecord::Migration
  def change
    change_column :claims, :fee, :decimal, precision: 8, scale: 2, default: 0.0
    add_column :claims, :minimum, :decimal, precision: 8, scale: 2, default: 0.0
  end
end
