class AddTicketCodeToCredentialTransactions < ActiveRecord::Migration
  def change
    add_column :credential_transactions, :ticket_code, :string
  end
end
