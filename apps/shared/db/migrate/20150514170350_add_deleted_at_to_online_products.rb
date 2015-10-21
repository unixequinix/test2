class AddDeletedAtToOnlineProducts < ActiveRecord::Migration
  def change
    add_column :online_products, :deleted_at, :datetime
    add_index :online_products, :deleted_at
  end
end
