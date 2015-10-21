class ChangeEventInCustomers < ActiveRecord::Migration
  def change
    change_column :customers, :event_id, :integer, null: false
    add_index :customers, [:email, :event_id], unique: true
  end
end
