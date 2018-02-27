class ChangeDefaultValueToSymbolAttribute < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:catalog_items, :symbol, 'C')
  end
end
