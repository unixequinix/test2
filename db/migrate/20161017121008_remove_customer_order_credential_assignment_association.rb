class RemoveCustomerOrderCredentialAssignmentAssociation < ActiveRecord::Migration
  def change
    drop_table :c_assignments_c_orders
  end
end
