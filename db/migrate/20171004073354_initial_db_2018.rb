class InitialDb2018 < ActiveRecord::Migration[5.1]
  def change
    enable_extension "plpgsql"
    enable_extension "citext"

    create_table :access_control_gates do |t|
      t.integer :access_id, null: false
      t.string :direction, null: false
      t.boolean :hidden
      t.integer :station_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["access_id"], name: "index_access_control_gates_on_access_id"
      t.index ["station_id"], name: "index_access_control_gates_on_station_id"
    end unless data_source_exists?(:access_control_gates)

    create_table :alerts do |t|
      t.bigint :event_id, null: false
      t.string :subject_type
      t.bigint :subject_id
      t.integer :priority, default: 0
      t.boolean :resolved, default: false
      t.string :body
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["event_id"], name: "index_alerts_on_event_id"
      t.index ["subject_type", "subject_id"], name: "index_alerts_on_subject_type_and_subject_id"
    end unless data_source_exists?(:alerts)

    create_table :catalog_items do |t|
      t.integer :event_id, null: false
      t.string :type, null: false
      t.string :name
      t.decimal :value, precision: 8, scale: 2, default: "1.0", null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :memory_position
      t.integer :memory_length, default: 1
      t.string :mode
      t.integer :role, default: 1, null: false
      t.integer :station_id
      t.integer :group
      t.string :symbol, default: "☉"
      t.index ["event_id"], name: "index_catalog_items_on_event_id"
      t.index ["memory_position", "event_id"], name: "index_catalog_items_on_memory_position_and_event_id", unique: true
      t.index ["station_id", "group", "role"], name: "index_catalog_items_on_station_id_and_group_and_role", unique: true
      t.index ["station_id"], name: "index_catalog_items_on_station_id"
    end unless data_source_exists?(:catalog_items)

    create_table :companies do |t|
      t.string :name, null: false
      t.string :access_token
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.boolean :hidden
      t.integer :event_id, null: false
      t.index ["event_id", "name"], name: "index_companies_on_event_id_and_name", unique: true
      t.index ["event_id"], name: "index_companies_on_event_id"
    end unless data_source_exists?(:companies)

    create_table :customers do |t|
      t.integer :event_id, null: false
      t.citext :email
      t.string :first_name
      t.string :last_name
      t.string :encrypted_password
      t.string :reset_password_token
      t.string :phone
      t.string :postcode
      t.string :address
      t.string :city
      t.string :country
      t.string :gender
      t.string :remember_token
      t.integer :sign_in_count, default: 0, null: false
      t.boolean :agreed_on_registration, default: false
      t.inet :last_sign_in_ip
      t.inet :current_sign_in_ip
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.datetime :birthdate
      t.boolean :receive_communications, default: false
      t.string :locale, default: "en"
      t.string :provider
      t.string :uid
      t.boolean :receive_communications_two, default: false
      t.boolean :banned
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.boolean :anonymous, default: true
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.index ["confirmation_token"], name: "index_customers_on_confirmation_token", unique: true
      t.index ["event_id"], name: "index_customers_on_event_id"
      t.index ["remember_token"], name: "index_customers_on_remember_token", unique: true
      t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
    end unless data_source_exists?(:customers)

    create_table :device_caches do |t|
      t.bigint :event_id
      t.string :category, default: "full", null: false
      t.string :app_version, default: "unknown", null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :file_file_name
      t.string :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at
      t.index ["event_id"], name: "index_device_caches_on_event_id"
    end unless data_source_exists?(:device_caches)

    create_table :device_registrations do |t|
      t.integer :device_id, null: false
      t.integer :event_id, null: false
      t.boolean :allowed, default: true
      t.integer :battery, default: 0, null: false
      t.integer :number_of_transactions, default: 0, null: false
      t.integer :server_transactions, default: 0, null: false
      t.string :action
      t.datetime :created_at
      t.datetime :updated_at
      t.string :app_version
      t.datetime :current_time
      t.index ["device_id"], name: "index_device_registrations_on_device_id"
      t.index ["event_id"], name: "index_device_registrations_on_event_id"
    end unless data_source_exists?(:device_registrations)

    create_table :device_transactions do |t|
      t.integer :event_id, null: false
      t.string :action
      t.string :device_uid
      t.string :initialization_type
      t.integer :number_of_transactions, default: 0, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :battery
      t.integer :counter, default: 0, null: false
      t.integer :device_id, null: false
      t.integer :server_transactions, null: false
      t.string :app_version
      t.index ["device_id"], name: "index_device_transactions_on_device_id"
      t.index ["event_id"], name: "index_device_transactions_on_event_id"
    end unless data_source_exists?(:device_transactions)

    create_table :devices do |t|
      t.string :mac, null: false
      t.string :asset_tracker
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :serial
      t.index ["mac"], name: "index_devices_on_mac", unique: true
    end unless data_source_exists?(:devices)

    create_table :event_registrations do |t|
      t.integer :role
      t.string :email
      t.integer :event_id, null: false
      t.integer :user_id
      t.index ["event_id", "user_id"], name: "index_event_registrations_on_event_id_and_user_id", unique: true
      t.index ["event_id"], name: "index_event_registrations_on_event_id"
      t.index ["user_id"], name: "index_event_registrations_on_user_id"
    end unless data_source_exists?(:event_registrations)

    create_table :event_series do |t|
      t.string :name
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end unless data_source_exists?(:event_series)

    create_table :events do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :support_email, default: "support@glownet.com", null: false
      t.string :logo_file_name
      t.string :logo_content_type
      t.string :background_file_name
      t.string :background_content_type
      t.string :currency, default: "EUR", null: false
      t.string :token, null: false
      t.integer :logo_file_size
      t.integer :background_file_size
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false
      t.string :official_address
      t.string :registration_num
      t.string :official_name
      t.string :eventbrite_token
      t.string :eventbrite_event
      t.string :eventbrite_client_key
      t.string :eventbrite_client_secret
      t.string :timezone, default: "Madrid", null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.boolean :phone_mandatory
      t.boolean :gender_mandatory
      t.boolean :address_mandatory
      t.boolean :birthdate_mandatory
      t.boolean :agreed_event_condition
      t.boolean :receive_communications
      t.boolean :receive_communications_two
      t.string :gtag_type, default: "ultralight_c", null: false
      t.integer :maximum_gtag_balance, default: 300, null: false
      t.boolean :uid_reverse, default: false
      t.string :fast_removal_password, default: "123456", null: false
      t.string :private_zone_password, default: "123456", null: false
      t.integer :sync_time_gtags, default: 10, null: false
      t.integer :sync_time_tickets, default: 5, null: false
      t.integer :transaction_buffer, default: 100, null: false
      t.integer :days_to_keep_backup, default: 5, null: false
      t.integer :sync_time_customers, default: 10, null: false
      t.integer :sync_time_server_date, default: 1, null: false
      t.integer :sync_time_basic_download, default: 5, null: false
      t.integer :sync_time_event_parameters, default: 1, null: false
      t.string :gtag_key, null: false
      t.float :topup_fee, default: 0.0, null: false
      t.float :initial_topup_fee, default: 0.0, null: false
      t.float :gtag_deposit_fee, default: 0.0, null: false
      t.integer :state, default: 1, null: false
      t.integer :credit_step, default: 1, null: false
      t.integer :gtag_format, default: 0, null: false
      t.boolean :stations_apply_orders, default: true
      t.boolean :stations_initialize_gtags, default: true
      t.string :app_version, default: "all", null: false
      t.integer :bank_format, default: 0, null: false
      t.boolean :open_api, default: false
      t.boolean :open_portal, default: false
      t.boolean :open_refunds, default: false
      t.boolean :open_topups, default: false
      t.boolean :open_tickets, default: false
      t.boolean :open_gtags, default: false
      t.datetime :refunds_start_date
      t.datetime :refunds_end_date
      t.bigint :event_serie_id
      t.boolean :open_portal_intercom, default: false
      t.index ["slug"], name: "index_events_on_slug", unique: true
    end unless data_source_exists?(:events)

    create_table :friendly_id_slugs do |t|
      t.string :slug, null: false
      t.integer :sluggable_id, null: false
      t.string :sluggable_type, limit: 50
      t.string :scope
      t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
      t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
      t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
      t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
    end unless data_source_exists?(:friendly_id_slugs)

    create_table :gtags do |t|
      t.integer :event_id
      t.citext :tag_uid, null: false
      t.boolean :banned, default: false
      t.string :format, default: "wristband", null: false
      t.boolean :active, default: true
      t.decimal :credits, precision: 8, scale: 2, default: "0.0", null: false
      t.decimal :refundable_credits, precision: 8, scale: 2, default: "0.0", null: false
      t.decimal :final_balance, precision: 8, scale: 2, default: "0.0", null: false
      t.decimal :final_refundable_balance, precision: 8, scale: 2, default: "0.0", null: false
      t.integer :customer_id
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.boolean :redeemed, default: false
      t.integer :ticket_type_id
      t.index ["customer_id"], name: "index_gtags_on_customer_id"
      t.index ["event_id"], name: "index_gtags_on_event_id"
      t.index ["tag_uid", "event_id"], name: "index_gtags_on_tag_uid_and_event_id", unique: true
      t.index ["tag_uid"], name: "index_gtags_on_tag_uid"
      t.index ["ticket_type_id"], name: "index_gtags_on_ticket_type_id"
    end unless data_source_exists?(:gtags)

    create_table :old_products do |t|
      t.integer :event_id, null: false
      t.string :name
      t.boolean :is_alcohol, default: false
      t.string :description
      t.float :vat, default: 0.0
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["event_id"], name: "index_old_products_on_event_id"
    end unless data_source_exists?(:old_products)

    create_table :order_items do |t|
      t.integer :order_id, null: false
      t.integer :catalog_item_id, null: false
      t.decimal :amount, precision: 8, scale: 2, default: "0.0", null: false
      t.decimal :total, precision: 8, scale: 2, default: "0.0", null: false
      t.boolean :redeemed, default: false
      t.integer :counter, default: 0, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["catalog_item_id"], name: "index_order_items_on_catalog_item_id"
      t.index ["order_id"], name: "index_order_items_on_order_id"
    end unless data_source_exists?(:order_items)

    create_table :orders do |t|
      t.string :status, default: "in_progress", null: false
      t.datetime :completed_at
      t.jsonb :payment_data, default: "{}"
      t.string :gateway
      t.integer :customer_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :event_id, null: false
      t.jsonb :refund_data, default: "{}"
      t.string :ip
      t.index ["customer_id"], name: "index_orders_on_customer_id"
      t.index ["event_id"], name: "index_orders_on_event_id"
    end unless data_source_exists?(:orders)

    create_table :pack_catalog_items do |t|
      t.integer :pack_id, null: false
      t.integer :catalog_item_id, null: false
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["catalog_item_id"], name: "index_pack_catalog_items_on_catalog_item_id"
      t.index ["pack_id"], name: "index_pack_catalog_items_on_pack_id"
    end unless data_source_exists?(:pack_catalog_items)

    create_table :payment_gateways do |t|
      t.integer :event_id, null: false
      t.jsonb :data, default: "{}", null: false
      t.boolean :refund
      t.boolean :topup
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :refund_field_a_name, default: "iban"
      t.string :refund_field_b_name, default: "swift"
      t.integer :name
      t.decimal :fee, precision: 8, scale: 2, default: "0.0", null: false
      t.decimal :minimum, precision: 8, scale: 2, default: "0.0", null: false
      t.index ["event_id"], name: "index_payment_gateways_on_event_id"
    end unless data_source_exists?(:payment_gateways)

    create_table :products do |t|
      t.integer :old_product_id
      t.float :price, null: false
      t.integer :position
      t.boolean :hidden, default: false
      t.integer :station_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :name
      t.boolean :is_alcohol, default: false
      t.string :description
      t.float :vat, default: 0.0
      t.index ["station_id"], name: "index_products_on_station_id"
    end unless data_source_exists?(:products)

    create_table :refunds do |t|
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.string :status
      t.decimal :fee, precision: 8, scale: 2, default: "0.0", null: false
      t.string :field_a
      t.string :field_b
      t.integer :customer_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :event_id, null: false
      t.string :gateway, null: false
      t.string :ip
      t.index ["customer_id"], name: "index_refunds_on_customer_id"
      t.index ["event_id"], name: "index_refunds_on_event_id"
    end unless data_source_exists?(:refunds)

    create_table :sale_items do |t|
      t.integer :old_product_id
      t.integer :quantity, null: false
      t.float :unit_price, null: false
      t.integer :credit_transaction_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.bigint :product_id
      t.index ["credit_transaction_id"], name: "index_sale_items_on_credit_transaction_id"
      t.index ["product_id"], name: "index_sale_items_on_product_id"
    end unless data_source_exists?(:sale_items)

    create_table :station_catalog_items do |t|
      t.integer :catalog_item_id, null: false
      t.float :price, null: false
      t.boolean :hidden, default: false
      t.integer :station_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["catalog_item_id"], name: "index_station_catalog_items_on_catalog_item_id"
      t.index ["station_id"], name: "index_station_catalog_items_on_station_id"
    end unless data_source_exists?(:station_catalog_items)

    create_table :stations do |t|
      t.integer :event_id, null: false
      t.string :name, null: false
      t.string :location, default: ""
      t.string :category
      t.string :reporting_category
      t.string :address
      t.string :registration_num
      t.string :official_name
      t.integer :station_event_id, null: false
      t.boolean :hidden, default: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["event_id"], name: "index_stations_on_event_id"
      t.index ["station_event_id", "event_id"], name: "index_stations_on_station_event_id_and_event_id", unique: true
    end unless data_source_exists?(:stations)

    create_table :ticket_types do |t|
      t.integer :event_id, null: false
      t.string :name, null: false
      t.string :company_code
      t.boolean :hidden, default: false
      t.integer :catalog_item_id
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :company_id, null: false
      t.index ["catalog_item_id"], name: "index_ticket_types_on_catalog_item_id"
      t.index ["company_id"], name: "index_ticket_types_on_company_id"
      t.index ["event_id"], name: "index_ticket_types_on_event_id"
      t.index ["name", "company_id", "event_id"], name: "index_ticket_types_on_name_and_company_id_and_event_id", unique: true
    end unless data_source_exists?(:ticket_types)

    create_table :tickets do |t|
      t.integer :event_id, null: false
      t.integer :ticket_type_id, null: false
      t.citext :code, null: false
      t.boolean :redeemed, default: false, null: false
      t.boolean :banned, default: false
      t.string :purchaser_first_name
      t.string :purchaser_last_name
      t.string :purchaser_email
      t.integer :customer_id
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["code", "event_id"], name: "index_tickets_on_code_and_event_id", unique: true
      t.index ["customer_id"], name: "index_tickets_on_customer_id"
      t.index ["event_id"], name: "index_tickets_on_event_id"
      t.index ["ticket_type_id"], name: "index_tickets_on_ticket_type_id"
    end unless data_source_exists?(:tickets)

    create_table :topup_credits do |t|
      t.float :amount, null: false
      t.integer :credit_id, null: false
      t.boolean :hidden, default: false
      t.integer :station_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index ["credit_id"], name: "index_topup_credits_on_credit_id"
      t.index ["station_id"], name: "index_topup_credits_on_station_id"
    end unless data_source_exists?(:topup_credits)

    create_table :transactions do |t|
      t.integer :event_id, null: false
      t.string :type, null: false
      t.string :transaction_origin, null: false
      t.string :action, null: false
      t.citext :customer_tag_uid
      t.citext :operator_tag_uid
      t.integer :station_id
      t.string :device_uid
      t.integer :device_db_index
      t.string :device_created_at, null: false
      t.string :device_created_at_fixed
      t.integer :gtag_counter
      t.integer :counter
      t.string :status_message
      t.integer :status_code, default: 0, null: false
      t.integer :order_item_counter
      t.integer :access_id
      t.integer :direction
      t.string :final_access_value
      t.string :message
      t.citext :ticket_code
      t.float :credits
      t.float :refundable_credits
      t.float :final_balance
      t.float :final_refundable_balance
      t.integer :catalog_item_id
      t.float :items_amount
      t.float :price
      t.string :payment_method
      t.string :payment_gateway
      t.integer :ticket_id
      t.integer :priority
      t.string :operator_value
      t.integer :operator_station_id
      t.integer :order_id
      t.integer :gtag_id
      t.integer :customer_id
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.boolean :executed
      t.string :user_flag
      t.boolean :user_flag_active
      t.float :other_amount_credits
      t.index ["access_id"], name: "index_transactions_on_access_id"
      t.index ["action"], name: "index_transactions_on_action"
      t.index ["catalog_item_id"], name: "index_transactions_on_catalog_item_id"
      t.index ["customer_id"], name: "index_transactions_on_customer_id"
      t.index ["device_uid"], name: "index_transactions_on_device_uid"
      t.index ["event_id", "device_uid", "device_db_index", "device_created_at_fixed", "gtag_counter"], name: "index_transactions_on_device_columns", unique: true
      t.index ["event_id"], name: "index_transactions_on_event_id"
      t.index ["gtag_id"], name: "index_transactions_on_gtag_id"
      t.index ["operator_station_id"], name: "index_transactions_on_operator_station_id"
      t.index ["order_id"], name: "index_transactions_on_order_id"
      t.index ["station_id"], name: "index_transactions_on_station_id"
      t.index ["ticket_id"], name: "index_transactions_on_ticket_id"
      t.index ["type"], name: "index_transactions_on_type"
    end unless data_source_exists?(:transactions)

    create_table :users do |t|
      t.citext :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :access_token, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :role, default: 1
      t.string :username, null: false
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
      t.index ["username"], name: "index_users_on_username", unique: true
    end unless data_source_exists?(:users)

    add_foreign_key("access_control_gates", "stations") unless foreign_key_exists?("access_control_gates", "stations")
    add_foreign_key("alerts", "events") unless foreign_key_exists?("alerts", "events")
    add_foreign_key("catalog_items", "events") unless foreign_key_exists?("catalog_items", "events")
    add_foreign_key("catalog_items", "stations") unless foreign_key_exists?("catalog_items", "stations")
    add_foreign_key("companies", "events") unless foreign_key_exists?("companies", "events")
    add_foreign_key("customers", "events") unless foreign_key_exists?("customers", "events")
    add_foreign_key("device_caches", "events") unless foreign_key_exists?("device_caches", "events")
    add_foreign_key("device_registrations", "devices") unless foreign_key_exists?("device_registrations", "devices")
    add_foreign_key("device_registrations", "events") unless foreign_key_exists?("device_registrations", "events")
    add_foreign_key("device_transactions", "devices") unless foreign_key_exists?("device_transactions", "devices")
    add_foreign_key("device_transactions", "events") unless foreign_key_exists?("device_transactions", "events")
    add_foreign_key("gtags", "customers") unless foreign_key_exists?("gtags", "customers")
    add_foreign_key("gtags", "events") unless foreign_key_exists?("gtags", "events")
    add_foreign_key("gtags", "ticket_types") unless foreign_key_exists?("gtags", "ticket_types")
    add_foreign_key("old_products", "events") unless foreign_key_exists?("old_products", "events")
    add_foreign_key("order_items", "catalog_items") unless foreign_key_exists?("order_items", "catalog_items")
    add_foreign_key("order_items", "orders") unless foreign_key_exists?("order_items", "orders")
    add_foreign_key("orders", "customers") unless foreign_key_exists?("orders", "customers")
    add_foreign_key("orders", "events") unless foreign_key_exists?("orders", "events")
    add_foreign_key("pack_catalog_items", "catalog_items") unless foreign_key_exists?("pack_catalog_items", "catalog_items")
    add_foreign_key("payment_gateways", "events") unless foreign_key_exists?("payment_gateways", "events")
    add_foreign_key("products", "old_products") unless foreign_key_exists?("products", "old_products")
    add_foreign_key("products", "stations") unless foreign_key_exists?("products", "stations")
    add_foreign_key("refunds", "customers") unless foreign_key_exists?("refunds", "customers")
    add_foreign_key("refunds", "events") unless foreign_key_exists?("refunds", "events")
    add_foreign_key("sale_items", "products") unless foreign_key_exists?("sale_items", "products")
    add_foreign_key("sale_items", "transactions", column: "credit_transaction_id") unless foreign_key_exists?("sale_items", "transactions")
    add_foreign_key("station_catalog_items", "catalog_items") unless foreign_key_exists?("station_catalog_items", "catalog_items")
    add_foreign_key("station_catalog_items", "stations") unless foreign_key_exists?("station_catalog_items", "stations")
    add_foreign_key("stations", "events") unless foreign_key_exists?("stations", "events")
    add_foreign_key("ticket_types", "catalog_items") unless foreign_key_exists?("ticket_types", "catalog_items")
    add_foreign_key("ticket_types", "companies") unless foreign_key_exists?("ticket_types", "companies")
    add_foreign_key("ticket_types", "events") unless foreign_key_exists?("ticket_types", "events")
    add_foreign_key("tickets", "customers") unless foreign_key_exists?("tickets", "customers")
    add_foreign_key("tickets", "events") unless foreign_key_exists?("tickets", "events")
    add_foreign_key("tickets", "ticket_types") unless foreign_key_exists?("tickets", "ticket_types")
    add_foreign_key("topup_credits", "stations") unless foreign_key_exists?("topup_credits", "stations")
    add_foreign_key("transactions", "catalog_items") unless foreign_key_exists?("transactions", "catalog_items")
    add_foreign_key("transactions", "customers") unless foreign_key_exists?("transactions", "customers")
    add_foreign_key("transactions", "events") unless foreign_key_exists?("transactions", "events")
    add_foreign_key("transactions", "gtags") unless foreign_key_exists?("transactions", "gtags")
    add_foreign_key("transactions", "orders") unless foreign_key_exists?("transactions", "orders")
    add_foreign_key("transactions", "stations") unless foreign_key_exists?("transactions", "stations")
    add_foreign_key("transactions", "tickets") unless foreign_key_exists?("transactions", "tickets")
  end
end
