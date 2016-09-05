class AddEventbriteToEvents < ActiveRecord::Migration
  def change
    add_column :events, :eventbrite_token, :string
    add_column :events, :eventbrite_event, :string
    add_column :events, :eventbrite_client_key, :string
    add_column :events, :eventbrite_client_secret, :string
  end
end
