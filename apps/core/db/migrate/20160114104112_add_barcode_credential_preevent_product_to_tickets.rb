class AddBarcodeCredentialPreeventToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :barcode, :string, null: false
    add_column :tickets, :credential_redeemed, :boolean, null: false, default: true
    add_column :tickets, :preevent_product_id, :integer
  end
end