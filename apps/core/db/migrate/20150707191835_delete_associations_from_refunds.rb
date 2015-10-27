class DeleteAssociationsFromRefunds < ActiveRecord::Migration
  def change
    remove_column :refunds, :customer_id
    remove_column :refunds, :gtag_id
    remove_column :refunds, :bank_account_id
    remove_column :refunds, :aasm_state
  end
end
