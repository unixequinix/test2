class AddReceiveCommunicationsTwoToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :receive_communications_two, :boolean, default: false
  end
end
