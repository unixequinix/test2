class AddCredentialRedeemedCompanyTicketTypeToGtags
  def change
    add_column :preevent_products, :credential_redeemed, :boolean, null: false, default: false
    add_column :preevent_products, :company_ticket_type_id, :integer, null: true
  end
end