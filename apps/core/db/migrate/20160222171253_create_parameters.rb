class CreateParameters < ActiveRecord::Migration
  def change
    create_table :parameters do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :group, null: false
      t.string :data_type, null: false
      t.string :description

      t.timestamps null: false
    end
    add_index :parameters, [:name, :group, :category], unique: true
  end
end
