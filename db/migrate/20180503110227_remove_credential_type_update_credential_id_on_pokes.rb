class RemoveCredentialTypeUpdateCredentialIdOnPokes < ActiveRecord::Migration[5.1]
  def change
    remove_column :pokes, :credential_type, :integer
    rename_column :pokes, :credential_id, :ticket_id
  end
end
