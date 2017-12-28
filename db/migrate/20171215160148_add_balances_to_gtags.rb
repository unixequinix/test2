class AddBalancesToGtags < ActiveRecord::Migration[5.1]
  def change
    add_column :gtags, :balances, :jsonb, default: {}
  end
end
