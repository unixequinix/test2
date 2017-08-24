class AddCurrenciesToStats < ActiveRecord::Migration[5.1]
  def change
    add_column :stats, :event_currency, :string
    add_column :stats, :credit_symbol, :string
  end
end
