class AddUniverseToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :universe_token, :string
    add_column :events, :universe_event, :string
    add_column :events, :universe_client_secret, :string
    add_column :events, :universe_client_key, :string
  end
end