class ChangeTokenSymbolDefaultValue < ActiveRecord::Migration
  def change
    change_column_default :events, :token_symbol, "t"
  end
end
