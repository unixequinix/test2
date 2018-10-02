class AddCreatedAtInPokes < ActiveRecord::Migration[5.1]
  def change
    add_column :pokes, :created_at, :datetime
  end
end
