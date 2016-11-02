class CreateCredentialAssignmentsCustomerOrders < ActiveRecord::Migration
  def change
    create_table :c_assignments_c_orders do |t|
      t.belongs_to :credential_assignment, index: true
      t.belongs_to :customer_order, index: true
    end
  end
end
