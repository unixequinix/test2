class ChangeItemsAmountToFloat < ActiveRecord::Migration
  def change
    change_column :money_transactions, :items_amount, :float
  end
end
