class AddCustomerComplianceToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :customer_compliance, :boolean, default: false
  end
end
