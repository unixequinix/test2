class AddDefaultValueToCustomers < ActiveRecord::Migration
  def change
    change_column_default :customers, :receive_communications, false
    Customer.update_all(receive_communications: false)
  end
end
