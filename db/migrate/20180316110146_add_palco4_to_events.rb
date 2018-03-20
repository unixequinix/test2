class AddPalco4ToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :palco4_token, :string
    add_column :events, :palco4_event, :string
  end
end
