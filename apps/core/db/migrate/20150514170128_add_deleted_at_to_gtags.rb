class AddDeletedAtToGtags < ActiveRecord::Migration
  def change
    add_column :gtags, :deleted_at, :datetime
    add_index :gtags, :deleted_at
  end
end
