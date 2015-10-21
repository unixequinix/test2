class ChangeIndexInCustomers < ActiveRecord::Migration
  def change
    remove_index :customers, :email
    add_index :customers, :email
  end
end
