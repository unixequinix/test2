class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :aasm_state
      t.string :slug, null: false, index: { unique: true }
      t.string :location
      t.string :support_email, default: "support@glownet.com", null: false
      t.string :logo_file_name
      t.string :logo_content_type
      t.string :background_file_name
      t.string :background_content_type
      t.string :url
      t.string :background_type, default: "fixed"
      t.string :currency, default: "USD", null: false
      t.string :host_country, default: "US", null: false
      t.string :payment_service, default: "redsys"
      t.string :token
      t.text :description
      t.text :style
      t.integer :logo_file_size
      t.integer :background_file_size
      t.integer :features, default: 0, null: false
      t.integer :registration_parameters, default: 0, null: false
      t.integer :locales, default: 1, null: false
      t.integer :refund_services, default: 0, null: false
      t.boolean :gtag_assignation, default: true, null: false
      t.boolean :ticket_assignation, default: true, null: false
      t.datetime :logo_updated_at
      t.datetime :background_updated_at
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end
