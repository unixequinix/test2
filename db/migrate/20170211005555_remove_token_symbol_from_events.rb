class RemoveTokenSymbolFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :token_symbol, :string
  end
end
