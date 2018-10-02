class AddPricesToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :prices, :jsonb, default: {}
  end
end
