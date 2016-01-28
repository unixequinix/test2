class AddCredentialRedeemedCompanyTicketTypeToGtags < ActiveRecord::Migration
  def change
    add_column :gtags, :credential_redeemed, :boolean, null: false, default: false
    add_column :gtags, :company_ticket_type_id, :integer, null: true
  end
end