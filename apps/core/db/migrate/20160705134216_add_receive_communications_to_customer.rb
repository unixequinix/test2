class AddReceiveCommunicationsToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :receive_communications, :boolean
  end
end
