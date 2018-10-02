class AddTokensToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :tokens, :jsonb, default: {}
  end
end
