class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.integer :counter, null: false, default: 0
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
