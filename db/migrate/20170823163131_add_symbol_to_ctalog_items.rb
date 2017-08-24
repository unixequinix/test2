class AddSymbolToCtalogItems < ActiveRecord::Migration[5.1]
  def change
    add_column :catalog_items, :symbol, :string, default: "☉"
    change_column_default :events, :currency, to: "EUR", from: "USD"
  end
end
