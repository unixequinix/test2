class DropCredentialAssignments < ActiveRecord::Migration
  def change
    drop_table :credential_assignments
  end
end
