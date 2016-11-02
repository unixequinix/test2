class ChangeFinalBalanceName < ActiveRecord::Migration
  def change
    rename_column :access_transactions, :final_balance, :final_access_value
  end
end
