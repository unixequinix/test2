class AddTokenSymbolToEvents < ActiveRecord::Migration
  def change
    add_column :events, :token_symbol, :string
  end
end
