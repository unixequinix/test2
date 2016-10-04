class ChangesMultipleIndexes < ActiveRecord::Migration
  def change
    remove_index :gtags, [:tag_uid, :event_id]
    add_index :gtags, [:deleted_at, :tag_uid, :event_id], unique: true

    remove_index :customers, :email
    add_index :customers, [:deleted_at, :email, :event_id], unique: true

    remove_index :credential_assignments, :deleted_at
    add_index :credential_assignments,
              [:credentiable_type, :aasm_state],
              unique: true,
              name: "index_c_assignments_on_c_type_and_state"
  end
end
