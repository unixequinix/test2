class RemoveIntegrationsFromEvent < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :eventbrite_token
    remove_column :events, :eventbrite_event
    remove_column :events, :eventbrite_client_key
    remove_column :events, :eventbrite_client_secret
    remove_column :events, :universe_token
    remove_column :events, :universe_event
    remove_column :events, :universe_client_secret
    remove_column :events, :universe_client_key
    remove_column :events, :palco4_token
    remove_column :events, :palco4_event
  end
end
