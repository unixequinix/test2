class AddAddressAndRegistrationNumToStations < ActiveRecord::Migration
  def change
    add_column :stations, :address, :string
    add_column :stations, :registration_num, :string
  end
end
