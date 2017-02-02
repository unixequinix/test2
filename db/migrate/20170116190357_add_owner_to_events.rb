class AddOwnerToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :owner_id, :integer, foreign_key: true, index: true unless column_exists?(:events, :owner_id)
  end
end
