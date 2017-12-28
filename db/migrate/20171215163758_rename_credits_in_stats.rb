class RenameCreditsInStats < ActiveRecord::Migration[5.1]
  def change
    rename_column :gtags, :credits, :virtual_credits
    rename_column :gtags, :refundable_credits, :credits
    rename_column :gtags, :final_balance, :final_virtual_balance
    rename_column :gtags, :final_refundable_balance, :final_balance
  end
end
