class InitSchema < ActiveRecord::Migration[5.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    enable_extension "citext"
    create_table "access_control_gates", force: :cascade do |t|
      t.integer "access_id", null: false
      t.string "direction", null: false
      t.boolean "hidden"
      t.integer "station_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["access_id"], name: "index_access_control_gates_on_access_id"
      t.index ["station_id"], name: "index_access_control_gates_on_station_id"
    end
    create_table "alerts", force: :cascade do |t|
      t.bigint "event_id", null: false
      t.string "subject_type"
      t.bigint "subject_id"
      t.integer "priority", default: 0
      t.boolean "resolved", default: false
      t.string "body"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["event_id"], name: "index_alerts_on_event_id"
      t.index ["subject_type", "subject_id"], name: "index_alerts_on_subject_type_and_subject_id"
    end
    create_table "api_metrics", force: :cascade do |t|
      t.bigint "user_id"
      t.bigint "event_id"
      t.string "controller", null: false
      t.string "action", null: false
      t.string "http_verb", null: false
      t.jsonb "request_params", default: "{}"
      t.datetime "received_at"
      t.string "response"
      t.index ["event_id"], name: "index_api_metrics_on_event_id"
      t.index ["user_id"], name: "index_api_metrics_on_user_id"
    end
    create_table "catalog_items", force: :cascade do |t|
      t.integer "event_id", null: false
      t.string "type", null: false
      t.string "name"
      t.decimal "value", precision: 8, scale: 2, default: "1.0", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "memory_position"
      t.integer "memory_length", default: 1
      t.string "mode"
      t.integer "role", default: 1, null: false
      t.integer "station_id"
      t.integer "group"
      t.string "symbol", default: "C"
      t.index ["event_id"], name: "index_catalog_items_on_event_id"
      t.index ["memory_position", "event_id"], name: "index_catalog_items_on_memory_position_and_event_id", unique: true
      t.index ["station_id", "group", "role"], name: "index_catalog_items_on_station_id_and_group_and_role", unique: true
      t.index ["station_id"], name: "index_catalog_items_on_station_id"
    end
    create_table "customers", force: :cascade do |t|
      t.integer "event_id", null: false
      t.citext "email"
      t.string "first_name"
      t.string "last_name"
      t.string "encrypted_password"
      t.string "reset_password_token"
      t.string "phone"
      t.string "postcode"
      t.string "address"
      t.string "city"
      t.string "country"
      t.string "gender"
      t.string "remember_token"
      t.integer "sign_in_count", default: 0, null: false
      t.boolean "agreed_on_registration", default: false
      t.inet "last_sign_in_ip"
      t.inet "current_sign_in_ip"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.datetime "birthdate"
      t.boolean "receive_communications", default: false
      t.string "locale", default: "en"
      t.string "provider"
      t.string "uid"
      t.boolean "receive_communications_two", default: false
      t.boolean "banned"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "anonymous", default: true
      t.string "confirmation_token"
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.boolean "operator", default: false
      t.boolean "initial_topup_fee_paid", default: false
      t.string "avatar_file_name"
      t.string "avatar_content_type"
      t.integer "avatar_file_size"
      t.datetime "avatar_updated_at"
      t.index ["confirmation_token"], name: "index_customers_on_confirmation_token", unique: true
      t.index ["event_id", "email"], name: "index_customers_on_event_id_and_email", unique: true
      t.index ["event_id"], name: "index_customers_on_event_id"
      t.index ["remember_token"], name: "index_customers_on_remember_token", unique: true
      t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
    end
    create_table "device_caches", force: :cascade do |t|
      t.bigint "event_id"
      t.string "category", default: "full", null: false
      t.string "app_version", default: "unknown", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "file_file_name"
      t.string "file_content_type"
      t.integer "file_file_size"
      t.datetime "file_updated_at"
      t.index ["event_id"], name: "index_device_caches_on_event_id"
    end
    create_table "device_registrations", force: :cascade do |t|
      t.integer "device_id", null: false
      t.integer "event_id", null: false
      t.boolean "allowed", default: true
      t.integer "battery", default: 0, null: false
      t.integer "number_of_transactions", default: 0, null: false
      t.integer "server_transactions", default: 0, null: false
      t.string "action"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "app_version"
      t.datetime "current_time"
      t.string "initialization_type"
      t.index ["device_id"], name: "index_device_registrations_on_device_id"
      t.index ["event_id"], name: "index_device_registrations_on_event_id"
    end
    create_table "device_transactions", force: :cascade do |t|
      t.integer "event_id", null: false
      t.string "action"
      t.string "device_uid"
      t.string "initialization_type"
      t.integer "number_of_transactions", default: 0, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "battery"
      t.integer "counter", default: 0, null: false
      t.integer "device_id", null: false
      t.integer "server_transactions", null: false
      t.string "app_version"
      t.index ["device_id"], name: "index_device_transactions_on_device_id"
      t.index ["event_id"], name: "index_device_transactions_on_event_id"
    end
    create_table "devices", force: :cascade do |t|
      t.citext "mac"
      t.citext "asset_tracker"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "serial"
      t.integer "team_id", null: false
      t.string "serie"
      t.string "app_id", null: false
      t.string "imei"
      t.string "manufacturer"
      t.string "device_model"
      t.string "android_version"
      t.jsonb "extra_info", default: {}
      t.index ["app_id"], name: "index_devices_on_app_id", unique: true
    end
    create_table "event_registrations", force: :cascade do |t|
      t.integer "role"
      t.string "email"
      t.integer "event_id", null: false
      t.integer "user_id"
      t.index ["event_id", "user_id"], name: "index_event_registrations_on_event_id_and_user_id", unique: true
      t.index ["event_id"], name: "index_event_registrations_on_event_id"
      t.index ["user_id"], name: "index_event_registrations_on_user_id"
    end
    create_table "event_series", force: :cascade do |t|
      t.string "name"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "events", force: :cascade do |t|
      t.string "name", null: false
      t.string "slug", null: false
      t.string "support_email", default: "support@glownet.com", null: false
      t.string "logo_file_name"
      t.string "logo_content_type"
      t.string "background_file_name"
      t.string "background_content_type"
      t.string "currency", default: "EUR", null: false
      t.integer "logo_file_size"
      t.integer "background_file_size"
      t.datetime "start_date", null: false
      t.datetime "end_date", null: false
      t.string "official_address"
      t.string "registration_num"
      t.string "official_name"
      t.string "eventbrite_token"
      t.string "eventbrite_event"
      t.string "eventbrite_client_key"
      t.string "eventbrite_client_secret"
      t.string "timezone", default: "Madrid", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "phone_mandatory"
      t.boolean "gender_mandatory"
      t.boolean "address_mandatory"
      t.boolean "birthdate_mandatory"
      t.boolean "agreed_event_condition"
      t.boolean "receive_communications"
      t.boolean "receive_communications_two"
      t.string "gtag_type", default: "ultralight_c", null: false
      t.integer "maximum_gtag_balance", default: 300, null: false
      t.boolean "uid_reverse", default: false
      t.string "fast_removal_password", default: "123456", null: false
      t.string "private_zone_password", default: "123456", null: false
      t.integer "sync_time_gtags", default: 10, null: false
      t.integer "sync_time_tickets", default: 5, null: false
      t.integer "transaction_buffer", default: 100, null: false
      t.integer "days_to_keep_backup", default: 5, null: false
      t.integer "sync_time_customers", default: 10, null: false
      t.integer "sync_time_server_date", default: 1, null: false
      t.integer "sync_time_basic_download", default: 5, null: false
      t.integer "sync_time_event_parameters", default: 1, null: false
      t.string "gtag_key", null: false
      t.float "every_topup_fee"
      t.float "onsite_initial_topup_fee"
      t.float "gtag_deposit_fee"
      t.integer "state", default: 1, null: false
      t.integer "credit_step", default: 1, null: false
      t.integer "gtag_format", default: 0, null: false
      t.boolean "stations_apply_orders", default: true
      t.boolean "stations_initialize_gtags", default: true
      t.string "app_version", default: "all", null: false
      t.integer "bank_format", default: 0, null: false
      t.boolean "open_devices_api", default: false
      t.boolean "open_portal", default: false
      t.boolean "open_refunds", default: false
      t.boolean "open_topups", default: false
      t.boolean "open_tickets", default: false
      t.boolean "open_gtags", default: false
      t.datetime "refunds_start_date"
      t.datetime "refunds_end_date"
      t.bigint "event_serie_id"
      t.boolean "open_portal_intercom", default: false
      t.boolean "open_api", default: false
      t.string "universe_token"
      t.string "universe_event"
      t.string "universe_client_secret"
      t.string "universe_client_key"
      t.string "accounting_code"
      t.boolean "stations_apply_tickets", default: false
      t.boolean "tips_enabled", default: false
      t.float "online_initial_topup_fee"
      t.float "refund_fee"
      t.integer "device_registrations_count", default: 0
      t.integer "devices_count", default: 0
      t.integer "transactions_count", default: 0
      t.integer "tickets_count", default: 0
      t.integer "catalog_items_count", default: 0
      t.integer "ticket_types_count", default: 0
      t.integer "gtags_count", default: 0
      t.integer "payment_gateways_count", default: 0
      t.integer "stations_count", default: 0
      t.integer "device_transactions_count", default: 0
      t.integer "user_flags_count", default: 0
      t.integer "accesses_count", default: 0
      t.integer "operator_permissions_count", default: 0
      t.integer "packs_count", default: 0
      t.integer "customers_count", default: 0
      t.integer "orders_count", default: 0
      t.integer "refunds_count", default: 0
      t.integer "event_registrations_count", default: 0
      t.integer "users_count", default: 0
      t.integer "stats_count", default: 0
      t.integer "alerts_count", default: 0
      t.integer "device_caches_count", default: 0
      t.integer "pokes_count", default: 0
      t.float "refund_minimum"
      t.text "refund_fields", default: [], array: true
      t.boolean "auto_refunds", default: false
      t.boolean "emv_enabled", default: false
      t.string "palco4_token"
      t.string "palco4_event"
      t.index ["slug"], name: "index_events_on_slug", unique: true
    end
    create_table "friendly_id_slugs", force: :cascade do |t|
      t.string "slug", null: false
      t.integer "sluggable_id", null: false
      t.string "sluggable_type", limit: 50
      t.string "scope"
      t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
      t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
      t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
      t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
    end
    create_table "gtags", force: :cascade do |t|
      t.integer "event_id"
      t.citext "tag_uid", null: false
      t.boolean "banned", default: false
      t.string "format", default: "wristband", null: false
      t.boolean "active", default: true
      t.decimal "virtual_credits", precision: 8, scale: 2, default: "0.0", null: false
      t.decimal "credits", precision: 8, scale: 2, default: "0.0", null: false
      t.decimal "final_virtual_balance", precision: 8, scale: 2, default: "0.0", null: false
      t.decimal "final_balance", precision: 8, scale: 2, default: "0.0", null: false
      t.integer "customer_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "redeemed", default: false
      t.integer "ticket_type_id"
      t.jsonb "balances", default: {}
      t.boolean "complete", default: true
      t.boolean "consistent", default: true
      t.index ["customer_id"], name: "index_gtags_on_customer_id"
      t.index ["event_id"], name: "index_gtags_on_event_id"
      t.index ["tag_uid", "event_id"], name: "index_gtags_on_tag_uid_and_event_id", unique: true
      t.index ["tag_uid"], name: "index_gtags_on_tag_uid"
      t.index ["ticket_type_id"], name: "index_gtags_on_ticket_type_id"
    end
    create_table "order_items", force: :cascade do |t|
      t.integer "order_id", null: false
      t.integer "catalog_item_id", null: false
      t.decimal "amount", precision: 8, scale: 2, default: "0.0", null: false
      t.boolean "redeemed", default: false
      t.integer "counter", default: 0, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["catalog_item_id"], name: "index_order_items_on_catalog_item_id"
      t.index ["order_id"], name: "index_order_items_on_order_id"
    end
    create_table "orders", force: :cascade do |t|
      t.datetime "completed_at"
      t.jsonb "payment_data", default: {}
      t.string "gateway"
      t.integer "customer_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "event_id", null: false
      t.string "ip"
      t.integer "status", default: 1
      t.decimal "money_fee", precision: 8, scale: 2, default: "0.0", null: false
      t.decimal "money_base", precision: 8, scale: 2, default: "0.0", null: false
      t.index ["customer_id"], name: "index_orders_on_customer_id"
      t.index ["event_id"], name: "index_orders_on_event_id"
    end
    create_table "pack_catalog_items", force: :cascade do |t|
      t.integer "pack_id", null: false
      t.integer "catalog_item_id", null: false
      t.integer "amount", default: 1, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["catalog_item_id"], name: "index_pack_catalog_items_on_catalog_item_id"
      t.index ["pack_id"], name: "index_pack_catalog_items_on_pack_id"
    end
    create_table "pokes", force: :cascade do |t|
      t.string "action", null: false
      t.string "description"
      t.bigint "event_id", null: false
      t.bigint "operation_id"
      t.string "source", null: false
      t.datetime "date"
      t.integer "line_counter"
      t.integer "gtag_counter"
      t.bigint "device_id"
      t.bigint "station_id"
      t.bigint "customer_id"
      t.bigint "customer_gtag_id"
      t.bigint "operator_id"
      t.bigint "operator_gtag_id"
      t.string "credential_type"
      t.bigint "credential_id"
      t.bigint "ticket_type_id"
      t.bigint "product_id"
      t.bigint "order_id"
      t.bigint "catalog_item_id"
      t.string "catalog_item_type"
      t.integer "sale_item_quantity"
      t.decimal "sale_item_unit_price", precision: 10, scale: 2
      t.decimal "sale_item_total_price", precision: 10, scale: 2
      t.decimal "standard_unit_price", precision: 10, scale: 2
      t.decimal "standard_total_price", precision: 10, scale: 2
      t.string "payment_method"
      t.decimal "monetary_quantity", precision: 10, scale: 2
      t.decimal "monetary_unit_price", precision: 10, scale: 2
      t.decimal "monetary_total_price", precision: 10, scale: 2
      t.string "credit_type"
      t.bigint "credit_id"
      t.string "credit_name"
      t.decimal "credit_amount", precision: 10, scale: 2
      t.decimal "final_balance", precision: 10, scale: 2
      t.string "message"
      t.integer "priority"
      t.boolean "user_flag_value"
      t.integer "access_direction"
      t.integer "error_code"
      t.integer "status_code"
      t.index ["catalog_item_id"], name: "index_pokes_on_catalog_item_id"
      t.index ["credential_type", "credential_id"], name: "index_pokes_on_credential_type_and_credential_id"
      t.index ["credit_type", "credit_id"], name: "index_pokes_on_credit_type_and_credit_id"
      t.index ["customer_gtag_id"], name: "index_pokes_on_customer_gtag_id"
      t.index ["customer_id"], name: "index_pokes_on_customer_id"
      t.index ["device_id"], name: "index_pokes_on_device_id"
      t.index ["event_id"], name: "index_pokes_on_event_id"
      t.index ["operation_id"], name: "index_pokes_on_operation_id"
      t.index ["operator_gtag_id"], name: "index_pokes_on_operator_gtag_id"
      t.index ["operator_id"], name: "index_pokes_on_operator_id"
      t.index ["order_id"], name: "index_pokes_on_order_id"
      t.index ["product_id"], name: "index_pokes_on_product_id"
      t.index ["station_id"], name: "index_pokes_on_station_id"
      t.index ["ticket_type_id"], name: "index_pokes_on_ticket_type_id"
    end
    create_table "products", force: :cascade do |t|
      t.float "price", null: false
      t.integer "position"
      t.boolean "hidden", default: false
      t.integer "station_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "name"
      t.boolean "is_alcohol", default: false
      t.string "description"
      t.float "vat", default: 0.0
      t.index ["station_id"], name: "index_products_on_station_id"
    end
    create_table "refunds", force: :cascade do |t|
      t.decimal "credit_base", precision: 8, scale: 2, default: "0.0", null: false
      t.decimal "credit_fee", precision: 8, scale: 2, default: "0.0", null: false
      t.string "field_a"
      t.string "field_b"
      t.integer "customer_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "event_id", null: false
      t.string "gateway", null: false
      t.string "ip"
      t.jsonb "fields", default: {}
      t.integer "status", default: 1
      t.index ["customer_id"], name: "index_refunds_on_customer_id"
      t.index ["event_id"], name: "index_refunds_on_event_id"
    end
    create_table "sale_items", force: :cascade do |t|
      t.integer "quantity", null: false
      t.float "standard_unit_price"
      t.integer "credit_transaction_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "product_id"
      t.string "sale_item_type"
      t.jsonb "payments", default: {}
      t.decimal "standard_total_price", precision: 10, scale: 2
      t.index ["credit_transaction_id"], name: "index_sale_items_on_credit_transaction_id"
      t.index ["product_id"], name: "index_sale_items_on_product_id"
    end
    create_table "station_catalog_items", force: :cascade do |t|
      t.integer "catalog_item_id", null: false
      t.float "price", null: false
      t.boolean "hidden", default: false
      t.integer "station_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["catalog_item_id"], name: "index_station_catalog_items_on_catalog_item_id"
      t.index ["station_id"], name: "index_station_catalog_items_on_station_id"
    end
    create_table "station_ticket_types", force: :cascade do |t|
      t.bigint "station_id"
      t.bigint "ticket_type_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["station_id"], name: "index_station_ticket_types_on_station_id"
      t.index ["ticket_type_id"], name: "index_station_ticket_types_on_ticket_type_id"
    end
    create_table "stations", force: :cascade do |t|
      t.integer "event_id", null: false
      t.string "name", null: false
      t.string "location", default: ""
      t.string "category"
      t.string "reporting_category"
      t.string "address"
      t.string "registration_num"
      t.string "official_name"
      t.integer "station_event_id", null: false
      t.boolean "hidden", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "device_stats_enabled", default: true
      t.index ["event_id", "name"], name: "index_stations_on_event_id_and_name", unique: true
      t.index ["event_id"], name: "index_stations_on_event_id"
      t.index ["station_event_id", "event_id"], name: "index_stations_on_station_event_id_and_event_id", unique: true
    end
    create_table "team_invitations", force: :cascade do |t|
      t.integer "user_id"
      t.integer "team_id"
      t.boolean "leader", default: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "email"
      t.boolean "active", default: false
      t.index ["team_id"], name: "index_team_invitations_on_team_id"
      t.index ["user_id", "team_id"], name: "index_team_invitations_on_user_id_and_team_id", unique: true
      t.index ["user_id"], name: "index_team_invitations_on_user_id"
    end
    create_table "teams", force: :cascade do |t|
      t.string "name"
    end
    create_table "ticket_types", force: :cascade do |t|
      t.integer "event_id", null: false
      t.string "name", null: false
      t.string "company_code"
      t.boolean "hidden", default: false
      t.integer "catalog_item_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "company", default: "Glownet"
      t.decimal "money_base", precision: 8, scale: 2, default: "0.0", null: false
      t.decimal "money_fee", precision: 8, scale: 2, default: "0.0", null: false
      t.index ["catalog_item_id"], name: "index_ticket_types_on_catalog_item_id"
      t.index ["event_id", "company", "name"], name: "index_ticket_types_on_event_id_and_company_and_name", unique: true
      t.index ["event_id"], name: "index_ticket_types_on_event_id"
    end
    create_table "tickets", force: :cascade do |t|
      t.integer "event_id", null: false
      t.integer "ticket_type_id", null: false
      t.citext "code", null: false
      t.boolean "redeemed", default: false, null: false
      t.boolean "banned", default: false
      t.string "purchaser_first_name"
      t.string "purchaser_last_name"
      t.string "purchaser_email"
      t.integer "customer_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["code", "event_id"], name: "index_tickets_on_code_and_event_id", unique: true
      t.index ["customer_id"], name: "index_tickets_on_customer_id"
      t.index ["event_id"], name: "index_tickets_on_event_id"
      t.index ["ticket_type_id"], name: "index_tickets_on_ticket_type_id"
    end
    create_table "topup_credits", force: :cascade do |t|
      t.float "amount", null: false
      t.integer "credit_id", null: false
      t.boolean "hidden", default: false
      t.integer "station_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["credit_id"], name: "index_topup_credits_on_credit_id"
      t.index ["station_id"], name: "index_topup_credits_on_station_id"
    end
    create_table "transactions", force: :cascade do |t|
      t.integer "event_id", null: false
      t.string "type", null: false
      t.string "transaction_origin", null: false
      t.string "action", null: false
      t.citext "customer_tag_uid"
      t.citext "operator_tag_uid"
      t.integer "station_id"
      t.string "device_uid"
      t.integer "device_db_index"
      t.string "device_created_at", null: false
      t.string "device_created_at_fixed"
      t.integer "gtag_counter"
      t.integer "counter"
      t.string "status_message"
      t.integer "status_code", default: 0, null: false
      t.integer "access_id"
      t.integer "direction"
      t.string "final_access_value"
      t.string "message"
      t.citext "ticket_code"
      t.float "credits"
      t.float "refundable_credits"
      t.float "final_balance"
      t.float "final_refundable_balance"
      t.integer "catalog_item_id"
      t.float "items_amount"
      t.float "price"
      t.string "payment_method"
      t.string "payment_gateway"
      t.integer "ticket_id"
      t.integer "priority"
      t.string "operator_value"
      t.integer "operator_station_id"
      t.integer "order_id"
      t.integer "gtag_id"
      t.integer "customer_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "executed"
      t.string "user_flag"
      t.boolean "user_flag_active"
      t.float "other_amount_credits"
      t.jsonb "payments", default: {}
      t.integer "operator_id"
      t.bigint "operator_gtag_id"
      t.bigint "order_item_id"
      t.integer "device_id"
      t.index ["access_id"], name: "index_transactions_on_access_id"
      t.index ["action"], name: "index_transactions_on_action"
      t.index ["catalog_item_id"], name: "index_transactions_on_catalog_item_id"
      t.index ["customer_id"], name: "index_transactions_on_customer_id"
      t.index ["device_id"], name: "index_transactions_on_device_id"
      t.index ["device_uid"], name: "index_transactions_on_device_uid"
      t.index ["event_id", "device_uid", "device_db_index", "device_created_at_fixed", "gtag_counter"], name: "index_transactions_on_device_columns", unique: true
      t.index ["event_id"], name: "index_transactions_on_event_id"
      t.index ["gtag_id"], name: "index_transactions_on_gtag_id"
      t.index ["operator_id"], name: "index_transactions_on_operator_id"
      t.index ["operator_station_id"], name: "index_transactions_on_operator_station_id"
      t.index ["order_id"], name: "index_transactions_on_order_id"
      t.index ["station_id"], name: "index_transactions_on_station_id"
      t.index ["ticket_id"], name: "index_transactions_on_ticket_id"
      t.index ["type"], name: "index_transactions_on_type"
    end
    create_table "users", force: :cascade do |t|
      t.citext "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "access_token", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "role", default: 1
      t.string "username", null: false
      t.string "avatar_file_name"
      t.string "avatar_content_type"
      t.integer "avatar_file_size"
      t.datetime "avatar_updated_at"
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
      t.index ["username"], name: "index_users_on_username", unique: true
    end
    create_table "versions", force: :cascade do |t|
      t.string "item_type", null: false
      t.integer "item_id", null: false
      t.string "event", null: false
      t.string "whodunnit"
      t.text "object"
      t.datetime "created_at"
      t.text "object_changes"
      t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    end
    add_foreign_key "access_control_gates", "stations"
    add_foreign_key "alerts", "events"
    add_foreign_key "api_metrics", "events"
    add_foreign_key "api_metrics", "users"
    add_foreign_key "catalog_items", "events"
    add_foreign_key "catalog_items", "stations"
    add_foreign_key "customers", "events"
    add_foreign_key "device_caches", "events"
    add_foreign_key "device_registrations", "devices"
    add_foreign_key "device_registrations", "events"
    add_foreign_key "device_transactions", "devices"
    add_foreign_key "device_transactions", "events"
    add_foreign_key "gtags", "customers"
    add_foreign_key "gtags", "events"
    add_foreign_key "gtags", "ticket_types"
    add_foreign_key "order_items", "catalog_items"
    add_foreign_key "order_items", "orders"
    add_foreign_key "orders", "customers"
    add_foreign_key "orders", "events"
    add_foreign_key "pack_catalog_items", "catalog_items"
    add_foreign_key "pokes", "catalog_items"
    add_foreign_key "pokes", "customers"
    add_foreign_key "pokes", "devices"
    add_foreign_key "pokes", "events"
    add_foreign_key "pokes", "orders"
    add_foreign_key "pokes", "products"
    add_foreign_key "pokes", "stations"
    add_foreign_key "pokes", "ticket_types"
    add_foreign_key "products", "stations"
    add_foreign_key "refunds", "customers"
    add_foreign_key "refunds", "events"
    add_foreign_key "sale_items", "products"
    add_foreign_key "sale_items", "transactions", column: "credit_transaction_id"
    add_foreign_key "station_catalog_items", "catalog_items"
    add_foreign_key "station_catalog_items", "stations"
    add_foreign_key "station_ticket_types", "stations"
    add_foreign_key "station_ticket_types", "ticket_types"
    add_foreign_key "stations", "events"
    add_foreign_key "ticket_types", "catalog_items"
    add_foreign_key "ticket_types", "events"
    add_foreign_key "tickets", "customers"
    add_foreign_key "tickets", "events"
    add_foreign_key "tickets", "ticket_types"
    add_foreign_key "topup_credits", "stations"
    add_foreign_key "transactions", "catalog_items"
    add_foreign_key "transactions", "customers"
    add_foreign_key "transactions", "events"
    add_foreign_key "transactions", "gtags"
    add_foreign_key "transactions", "orders"
    add_foreign_key "transactions", "stations"
    add_foreign_key "transactions", "tickets"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
