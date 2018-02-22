class RenameGtagConsitencyColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :gtags, :inconsistent, :consistent
    rename_column :gtags, :missing_transactions, :complete
  end
end
