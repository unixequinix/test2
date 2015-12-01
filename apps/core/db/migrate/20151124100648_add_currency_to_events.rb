class AddCurrencyToEvents < ActiveRecord::Migration
  def change
    add_column :events, :currency, :string, null: false
  end
end
