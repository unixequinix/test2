class RenameProductIdInStats < ActiveRecord::Migration[5.1]
  def change
    remove_column :stats, :product_id, :integer
    add_column :stats, :product_id, :integer
  end
end
