class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :description
      t.boolean :is_alcohol

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
