class RemoveReceiveCommunicationsFromCustomers < ActiveRecord::Migration[5.0]
  def change
    remove_column :customers, :agreed_event_condition, :boolean
  end
end
