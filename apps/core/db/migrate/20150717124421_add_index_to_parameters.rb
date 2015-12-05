class AddIndexToParameters < ActiveRecord::Migration
  def change
    change_column :parameters, :group, :string, null: false
    add_index :parameters, [:name, :group, :category], unique: true
  end
end
