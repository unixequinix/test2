class RemoveGtagBalanceFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :maximum_gtag_balance, :integer, default: 300
  end
end
