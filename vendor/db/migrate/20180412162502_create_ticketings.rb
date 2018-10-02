class CreateTicketings < ActiveRecord::Migration[5.1]
  def change
    create_table :ticketing_integrations do |t|
      t.belongs_to :event, null: false
      t.string :type, null: false
      t.integer :status, default: 0, null: false
      t.string :integration_event_id
      t.string :integration_event_name
      t.string :client_key
      t.string :client_secret
      t.string :token
      t.jsonb :data, default: {}
      t.index %w[event_id type integration_event_id], name: "index_ticketing_integrations_on_event", unique: true
    end
  end
end
