class AddAgreedEventConditionMessageToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :agreed_event_condition_message, :boolean
  end
end
