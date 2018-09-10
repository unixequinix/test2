class AddMaximumVirtualBalanceToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :maximum_gtag_virtual_balance, :integer, default: 300, null: false
  end
end
