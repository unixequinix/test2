class AddBarcodeCredentialPreeventProductToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :barcode, :string
    add_column :tickets, :credential_redeemed, :boolean, null: false, default: false
    add_column :tickets, :preevent_product_id, :integer
  end
end