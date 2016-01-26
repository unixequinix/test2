class AddValueCurrencyToCredits < ActiveRecord::Migration
  def change
    add_column :credits, :value, :decimal, precision: 8, scale: 2, default: 1.0, null: false
    add_column :credits, :currency, :string, null: false
  end
end
