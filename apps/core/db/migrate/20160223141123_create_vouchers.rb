class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
