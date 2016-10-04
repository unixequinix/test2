class AddOfficialAddressRegistrationNumAndOfficialNameToEvents < ActiveRecord::Migration
  def change
    add_column :events, :official_address, :string
    add_column :events, :registration_num, :string
    add_column :events, :official_name, :string
  end
end
