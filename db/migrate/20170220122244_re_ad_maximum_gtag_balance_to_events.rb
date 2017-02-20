class ReAdMaximumGtagBalanceToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :maximum_gtag_balance, :integer, default: 300 unless column_exists?(:events, :maximum_gtag_balance)
  end
end
