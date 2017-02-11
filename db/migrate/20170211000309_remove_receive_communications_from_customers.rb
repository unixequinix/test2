class RemoveReceiveCommunicationsFromCustomers < ActiveRecord::Migration[5.0]
  def change
    remove_column :customers, :receive_communications, :boolean
    remove_column :customers, :receive_communications_two, :boolean
    remove_column :customers, :agreed_event_condition, :boolean
  end
end
