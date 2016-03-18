class CreateProductsVouchers < ActiveRecord::Migration
  def change
    create_table :products_vouchers do |t|
      t.belongs_to :product, index: true
      t.belongs_to :voucher, index: true

      t.timestamps null: false
    end
  end
end
