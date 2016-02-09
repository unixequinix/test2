class CreatePurchasers < ActiveRecord::Migration
  def change
    create_table :purchasers do |t|
      t.references :credentiable, polymorphic: true, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :gtag_delivery_address

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
