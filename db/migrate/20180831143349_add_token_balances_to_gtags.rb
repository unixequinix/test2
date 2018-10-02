class AddTokenBalancesToGtags < ActiveRecord::Migration[5.1]
  def change
    add_column :gtags, :tokens, :jsonb, default: {}
    add_column :gtags, :final_tokens_balance, :jsonb, default: {}
  end
end
