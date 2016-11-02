class RemovesIndexInCredentialAssignments < ActiveRecord::Migration
  def change
    remove_index :credential_assignments, name: "index_c_assignments_on_c_type_and_state"
  end
end
