class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.boolean :standard, default: false, null: false
      t.decimal :value, precision: 8, scale: 2, default: 1.0, null: false
      t.string :currency

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
