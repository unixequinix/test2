class AddGdprAcceptanceToCustomers < ActiveRecord::Migration[5.1]
  def change
    remove_column :customers, :receive_communications, :boolean, default: false
    remove_column :customers, :receive_communications_two, :boolean, default: false

    add_column :customers, :gdpr_acceptance, :boolean, default: false
    add_column :customers, :gdpr_acceptance_at, :datetime
  end
end
