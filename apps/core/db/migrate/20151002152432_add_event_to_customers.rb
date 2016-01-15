class AddEventToCustomers < ActiveRecord::Migration
  def change
    remove_index :customers, :email
    change_column :customers, :email, :string, null: false, default: ''
    add_column :customers, :event_id, :integer
  end
end
