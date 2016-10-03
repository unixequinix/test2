class AddVatToProducts < ActiveRecord::Migration
  def change
    add_column :products, :vat, :float, default: 0.0
  end
end
