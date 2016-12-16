class InitialDatabase < ActiveRecord::Migration
  def change

    create_table "access_control_gates", force: :cascade do |t|
      t.integer  "access_id",                  null: false
      t.string   "direction",                  null: false
      t.datetime "created_at",                 null: false
      t.datetime "updated_at",                 null: false
      t.boolean  "hidden",     default: false
      t.integer  "station_id"
    end  unless table_exists?(:access_control_gates)

    add_index("access_control_gates", ["access_id"], name: "index_access_control_gates_on_access_id", using: :btree) unless index_exists?(:access_control_gates, :access_id)
    add_index("access_control_gates", ["station_id"], name: "index_access_control_gates_on_station_id", using: :btree) unless index_exists?(:access_control_gates, :station_id)

    create_table "admins", force: :cascade do |t|
      t.string   "email",                  default: "", null: false
      t.string   "encrypted_password",     default: "", null: false
      t.string   "access_token",                        null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          default: 0,  null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet     "current_sign_in_ip"
      t.inet     "last_sign_in_ip"
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
    end  unless table_exists?(:admins)

    add_index("admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree) unless index_exists?(:admins, :email)
    add_index("admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree) unless index_exists?(:admins, :reset_password_token)

    create_table "catalog_items", force: :cascade do |t|
      t.integer  "event_id",                                              null: false
      t.string   "type",                                                  null: false
      t.string   "name"
      t.integer  "initial_amount"
      t.integer  "step"
      t.integer  "max_purchasable"
      t.integer  "min_purchasable"
      t.datetime "created_at",                                            null: false
      t.datetime "updated_at",                                            null: false
      t.decimal  "value",           precision: 8, scale: 2, default: 1.0, null: false
    end  unless table_exists?(:catalog_items)

    add_index("catalog_items", ["event_id"], name: "index_catalog_items_on_event_id", using: :btree) unless index_exists?(:catalog_items, :event_id)

    create_table "companies", force: :cascade do |t|
      t.string   "name",         null: false
      t.string   "access_token"
      t.datetime "created_at",   null: false
      t.datetime "updated_at",   null: false
    end  unless table_exists?(:companies)

    create_table "company_event_agreements", force: :cascade do |t|
      t.integer  "company_id", null: false
      t.integer  "event_id",   null: false
      t.string   "aasm_state"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end  unless table_exists?(:company_event_agreements)

    add_index("company_event_agreements", ["company_id"], name: "index_company_event_agreements_on_company_id", using: :btree) unless index_exists?(:company_event_agreements, :company_id)
    add_index("company_event_agreements", ["event_id"], name: "index_company_event_agreements_on_event_id", using: :btree) unless index_exists?(:company_event_agreements, :event_id)

    create_table "customers", force: :cascade do |t|
      t.integer  "event_id",                                   null: false
      t.string   "email",                      default: "",    null: false
      t.string   "first_name",                 default: "",    null: false
      t.string   "last_name",                  default: "",    null: false
      t.string   "encrypted_password",         default: "",    null: false
      t.string   "reset_password_token"
      t.string   "phone"
      t.string   "postcode"
      t.string   "address"
      t.string   "city"
      t.string   "country"
      t.string   "gender"
      t.string   "remember_token"
      t.integer  "sign_in_count",              default: 0,     null: false
      t.boolean  "agreed_on_registration",     default: false
      t.boolean  "agreed_event_condition",     default: false
      t.inet     "last_sign_in_ip"
      t.inet     "current_sign_in_ip"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.datetime "birthdate"
      t.datetime "created_at",                                 null: false
      t.datetime "updated_at",                                 null: false
      t.boolean  "receive_communications",     default: false
      t.string   "locale",                     default: "en"
      t.string   "provider"
      t.string   "uid"
      t.boolean  "receive_communications_two", default: false
      t.boolean  "banned"
    end  unless table_exists?(:customers)

    add_index("customers", ["event_id"], name: "index_customers_on_event_id", using: :btree) unless index_exists?(:customers, :event_id)
    add_index("customers", ["remember_token"], name: "index_customers_on_remember_token", unique: true, using: :btree) unless index_exists?(:customers, :remember_token)
    add_index("customers", ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true, using: :btree) unless index_exists?(:customers, :reset_password_token)

    create_table "device_transactions", force: :cascade do |t|
      t.integer  "event_id"
      t.string   "action"
      t.string   "device_uid"
      t.integer  "device_db_index"
      t.string   "device_created_at"
      t.string   "device_created_at_fixed"
      t.string   "initialization_type"
      t.integer  "number_of_transactions"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "status_code",             default: 0
      t.string   "status_message"
    end  unless table_exists?(:device_transactions)

    add_index("device_transactions", ["event_id"], name: "index_device_transactions_on_event_id", using: :btree) unless index_exists?(:device_transactions, :event_id)

    create_table "devices", force: :cascade do |t|
      t.string   "device_model"
      t.string   "imei"
      t.string   "mac"
      t.string   "serial_number"
      t.datetime "created_at",    null: false
      t.datetime "updated_at",    null: false
      t.string   "asset_tracker"
    end  unless table_exists?(:devices)

    add_index("devices", ["mac", "imei", "serial_number"], name: "index_devices_on_mac_and_imei_and_serial_number", unique: true, using: :btree) unless index_exists?(:devices, [:mac, :imei, :serial_number])

    create_table "entitlements", force: :cascade do |t|
      t.integer  "access_id",                           null: false
      t.integer  "event_id",                            null: false
      t.integer  "memory_position",                     null: false
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
      t.integer  "memory_length",   default: 1
      t.string   "mode",            default: "counter"
    end  unless table_exists?(:entitlements)

    add_index("entitlements", ["access_id"], name: "index_entitlements_on_access_id", using: :btree) unless index_exists?(:entitlements, :access_id)
    add_index("entitlements", ["event_id"], name: "index_entitlements_on_event_id", using: :btree) unless index_exists?(:entitlements, :event_id)

    create_table "event_translations", force: :cascade do |t|
      t.integer  "event_id",                           null: false
      t.string   "locale",                             null: false
      t.string   "gtag_name"
      t.text     "info"
      t.text     "disclaimer"
      t.text     "refund_success_message"
      t.text     "mass_email_claim_notification"
      t.text     "gtag_assignation_notification"
      t.text     "gtag_form_disclaimer"
      t.text     "agreed_event_condition_message"
      t.text     "refund_disclaimer"
      t.text     "bank_account_disclaimer"
      t.datetime "created_at",                         null: false
      t.datetime "updated_at",                         null: false
      t.text     "receive_communications_message"
      t.text     "privacy_policy"
      t.text     "terms_of_use"
      t.text     "receive_communications_two_message"
    end  unless table_exists?(:event_translations)

    add_index("event_translations", ["event_id"], name: "index_event_translations_on_event_id", using: :btree) unless index_exists?(:event_translations, :event_id)
    add_index("event_translations", ["locale"], name: "index_event_translations_on_locale", using: :btree) unless index_exists?(:event_translations, :locale)

    create_table "events", force: :cascade do |t|
      t.string   "name",                                                         null: false
      t.string   "aasm_state"
      t.string   "slug",                                                         null: false
      t.string   "location"
      t.string   "support_email",                default: "support@glownet.com", null: false
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.string   "background_file_name"
      t.string   "background_content_type"
      t.string   "url"
      t.string   "background_type",              default: "fixed"
      t.string   "currency",                     default: "USD",                 null: false
      t.string   "host_country",                 default: "US",                  null: false
      t.string   "token"
      t.text     "style"
      t.integer  "logo_file_size"
      t.integer  "background_file_size"
      t.datetime "logo_updated_at"
      t.datetime "background_updated_at"
      t.datetime "start_date"
      t.datetime "end_date"
      t.datetime "created_at",                                                   null: false
      t.datetime "updated_at",                                                   null: false
      t.string   "token_symbol",                 default: "t"
      t.string   "company_name"
      t.string   "device_full_db_file_name"
      t.string   "device_full_db_content_type"
      t.integer  "device_full_db_file_size"
      t.datetime "device_full_db_updated_at"
      t.string   "device_basic_db_file_name"
      t.string   "device_basic_db_content_type"
      t.integer  "device_basic_db_file_size"
      t.datetime "device_basic_db_updated_at"
      t.string   "official_address"
      t.string   "registration_num"
      t.string   "official_name"
      t.string   "eventbrite_token"
      t.string   "eventbrite_event"
      t.string   "eventbrite_client_key"
      t.string   "eventbrite_client_secret"
      t.boolean  "ticket_assignation",           default: false
      t.boolean  "gtag_assignation",             default: false
      t.json     "registration_settings"
      t.json     "gtag_settings"
      t.json     "device_settings"
      t.string   "timezone"
    end  unless table_exists?(:events)

    add_index("events", ["slug"], name: "index_events_on_slug", unique: true, using: :btree) unless index_exists?(:events, :slug)

    create_table "friendly_id_slugs", force: :cascade do |t|
      t.string   "slug",                      null: false
      t.integer  "sluggable_id",              null: false
      t.string   "sluggable_type", limit: 50
      t.string   "scope"
      t.datetime "created_at",                null: false
      t.datetime "updated_at",                null: false
    end  unless table_exists?(:friendly_id_slugs)

    add_index("friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree) unless index_exists?(:friendly_id_slugs, :slug)
    add_index("friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree) unless index_exists?(:friendly_id_slugs, :slug)
    add_index("friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree) unless index_exists?(:friendly_id_slugs, :sluggable_id)
    add_index("friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree) unless index_exists?(:friendly_id_slugs, :sluggable_type)

    create_table "gtags", force: :cascade do |t|
      t.integer  "event_id",                                                               null: false
      t.string   "tag_uid",                                                                null: false
      t.datetime "created_at",                                                             null: false
      t.datetime "updated_at",                                                             null: false
      t.boolean  "banned",                                           default: false
      t.string   "format",                                           default: "wristband"
      t.integer  "activation_counter",                               default: 1
      t.boolean  "loyalty",                                          default: false
      t.boolean  "active",                                           default: true
      t.decimal  "credits",                  precision: 8, scale: 2
      t.decimal  "refundable_credits",       precision: 8, scale: 2
      t.decimal  "final_balance",            precision: 8, scale: 2
      t.decimal  "final_refundable_balance", precision: 8, scale: 2
      t.integer  "customer_id"
    end  unless table_exists?(:gtags)

    add_index("gtags", ["customer_id"], name: "index_gtags_on_customer_id", using: :btree) unless index_exists?(:gtags, :customer_id)
    add_index("gtags", ["event_id"], name: "index_gtags_on_event_id", using: :btree) unless index_exists?(:gtags, :event_id)

    create_table "order_items", force: :cascade do |t|
      t.integer  "order_id",                                null: false
      t.integer  "catalog_item_id",                         null: false
      t.decimal  "amount",          precision: 8, scale: 2
      t.decimal  "total",           precision: 8, scale: 2, null: false
      t.datetime "created_at",                              null: false
      t.datetime "updated_at",                              null: false
      t.boolean  "redeemed"
      t.integer  "counter"
    end  unless table_exists?(:order_items)

    add_index("order_items", ["catalog_item_id"], name: "index_order_items_on_catalog_item_id", using: :btree) unless index_exists?(:order_items, :catalog_item_id)
    add_index("order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree) unless index_exists?(:order_items, :order_id)

    create_table "orders", force: :cascade do |t|
      t.string   "status",       default: "in_progress", null: false
      t.datetime "completed_at"
      t.datetime "created_at",                           null: false
      t.datetime "updated_at",                           null: false
      t.json     "payment_data"
      t.string   "gateway"
      t.integer  "customer_id"
    end  unless table_exists?(:orders)

    add_index("orders", ["customer_id"], name: "index_orders_on_customer_id", using: :btree) unless index_exists?(:orders, :customer_id)

    create_table "pack_catalog_items", force: :cascade do |t|
      t.integer  "pack_id",                                 null: false
      t.integer  "catalog_item_id",                         null: false
      t.decimal  "amount",          precision: 8, scale: 2
      t.datetime "created_at",                              null: false
      t.datetime "updated_at",                              null: false
    end  unless table_exists?(:pack_catalog_items)

    add_index("pack_catalog_items", ["catalog_item_id"], name: "index_pack_catalog_items_on_catalog_item_id", using: :btree) unless index_exists?(:pack_catalog_items, :catalog_item_id)
    add_index("pack_catalog_items", ["pack_id"], name: "index_pack_catalog_items_on_pack_id", using: :btree) unless index_exists?(:pack_catalog_items, :pack_id)

    create_table "payment_gateways", force: :cascade do |t|
      t.integer  "event_id"
      t.string   "gateway"
      t.json     "data"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean  "refund"
      t.boolean  "topup"
    end  unless table_exists?(:payment_gateways)

    add_index("payment_gateways", ["event_id"], name: "index_payment_gateways_on_event_id", using: :btree) unless index_exists?(:payment_gateways, :event_id)

    create_table "products", force: :cascade do |t|
      t.string   "name"
      t.boolean  "is_alcohol",   default: false
      t.datetime "created_at",                   null: false
      t.datetime "updated_at",                   null: false
      t.string   "description"
      t.integer  "event_id"
      t.float    "vat",          default: 0.0
      t.string   "product_type"
    end  unless table_exists?(:products)

    add_index("products", ["event_id"], name: "index_products_on_event_id", using: :btree) unless index_exists?(:products, :event_id)

    create_table "refunds", force: :cascade do |t|
      t.decimal  "amount",      precision: 8, scale: 2, null: false
      t.string   "status"
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
      t.decimal  "fee",         precision: 8, scale: 2
      t.string   "iban"
      t.string   "swift"
      t.decimal  "money",       precision: 8, scale: 2
      t.integer  "customer_id"
    end  unless table_exists?(:refunds)

    add_index("refunds", ["customer_id"], name: "index_refunds_on_customer_id", using: :btree) unless index_exists?(:refunds, :customer_id)

    create_table "sale_items", force: :cascade do |t|
      t.integer "product_id"
      t.integer "quantity"
      t.float   "unit_price"
      t.integer "credit_transaction_id"
    end  unless table_exists?(:sale_items)

    add_index("sale_items", ["credit_transaction_id"], name: "index_sale_items_on_credit_transaction_id", using: :btree) unless index_exists?(:sale_items, :credit_transaction_id)
    add_index("sale_items", ["product_id"], name: "index_sale_items_on_product_id", using: :btree) unless index_exists?(:sale_items, :product_id)

    create_table "station_catalog_items", force: :cascade do |t|
      t.integer  "catalog_item_id",                 null: false
      t.float    "price",                           null: false
      t.datetime "created_at",                      null: false
      t.datetime "updated_at",                      null: false
      t.boolean  "hidden",          default: false
      t.integer  "station_id"
    end  unless table_exists?(:station_catalog_items)

    add_index("station_catalog_items", ["catalog_item_id"], name: "index_station_catalog_items_on_catalog_item_id", using: :btree) unless index_exists?(:station_catalog_items, :catalog_item_id)
    add_index("station_catalog_items", ["station_id"], name: "index_station_catalog_items_on_station_id", using: :btree) unless index_exists?(:station_catalog_items, :station_id)

    create_table "station_parameters", force: :cascade do |t|
      t.integer  "station_id",               null: false
      t.integer  "station_parametable_id",   null: false
      t.string   "station_parametable_type", null: false
      t.datetime "created_at",               null: false
      t.datetime "updated_at",               null: false
    end  unless table_exists?(:station_parameters)

    create_table "station_products", force: :cascade do |t|
      t.integer  "product_id",                 null: false
      t.float    "price",                      null: false
      t.datetime "created_at",                 null: false
      t.datetime "updated_at",                 null: false
      t.integer  "position"
      t.boolean  "hidden",     default: false
      t.integer  "station_id"
    end  unless table_exists?(:station_products)

    add_index("station_products", ["product_id"], name: "index_station_products_on_product_id", using: :btree) unless index_exists?(:station_products, :product_id)
    add_index("station_products", ["station_id"], name: "index_station_products_on_station_id", using: :btree) unless index_exists?(:station_products, :station_id)

    create_table "stations", force: :cascade do |t|
      t.integer  "event_id",                           null: false
      t.string   "name",                               null: false
      t.datetime "created_at",                         null: false
      t.datetime "updated_at",                         null: false
      t.string   "location",           default: ""
      t.integer  "position"
      t.string   "group"
      t.string   "category"
      t.string   "reporting_category"
      t.string   "address"
      t.string   "registration_num"
      t.string   "official_name"
      t.integer  "station_event_id"
      t.boolean  "hidden",             default: false
    end  unless table_exists?(:stations)

    add_index("stations", ["event_id"], name: "index_stations_on_event_id", using: :btree) unless index_exists?(:stations, :event_id)
    add_index("stations", ["station_event_id"], name: "index_stations_on_station_event_id", using: :btree) unless index_exists?(:stations, :station_event_id)

    create_table "ticket_types", force: :cascade do |t|
      t.integer  "event_id",                                   null: false
      t.integer  "company_event_agreement_id",                 null: false
      t.string   "name"
      t.string   "company_code"
      t.datetime "created_at",                                 null: false
      t.datetime "updated_at",                                 null: false
      t.boolean  "hidden",                     default: false
      t.integer  "catalog_item_id"
    end  unless table_exists?(:ticket_types)

    add_index("ticket_types", ["catalog_item_id"], name: "index_ticket_types_on_catalog_item_id", using: :btree) unless index_exists?(:ticket_types, :catalog_item_id)
    add_index("ticket_types", ["company_event_agreement_id"], name: "index_ticket_types_on_company_event_agreement_id", using: :btree) unless index_exists?(:ticket_types, :company_event_agreement_id)
    add_index("ticket_types", ["event_id"], name: "index_ticket_types_on_event_id", using: :btree) unless index_exists?(:ticket_types, :event_id)

    create_table "tickets", force: :cascade do |t|
      t.integer  "event_id",                             null: false
      t.integer  "ticket_type_id",                       null: false
      t.string   "code"
      t.boolean  "redeemed",             default: false, null: false
      t.datetime "created_at",                           null: false
      t.datetime "updated_at",                           null: false
      t.boolean  "banned",               default: false
      t.string   "purchaser_first_name"
      t.string   "purchaser_last_name"
      t.string   "purchaser_email"
      t.integer  "customer_id"
      t.string   "description"
    end  unless table_exists?(:tickets)

    add_index("tickets", ["customer_id"], name: "index_tickets_on_customer_id", using: :btree) unless index_exists?(:tickets, :customer_id)
    add_index("tickets", ["event_id"], name: "index_tickets_on_event_id", using: :btree) unless index_exists?(:tickets, :event_id)
    add_index("tickets", ["ticket_type_id"], name: "index_tickets_on_ticket_type_id", using: :btree) unless index_exists?(:tickets, :ticket_type_id)

    create_table "topup_credits", force: :cascade do |t|
      t.float    "amount"
      t.integer  "credit_id"
      t.datetime "created_at",                 null: false
      t.datetime "updated_at",                 null: false
      t.boolean  "hidden",     default: false
      t.integer  "station_id"
    end  unless table_exists?(:topup_credits)

    add_index("topup_credits", ["credit_id"], name: "index_topup_credits_on_credit_id", using: :btree) unless index_exists?(:topup_credits, :credit_id)
    add_index("topup_credits", ["station_id"], name: "index_topup_credits_on_station_id", using: :btree) unless index_exists?(:topup_credits, :station_id)

    create_table "transactions", force: :cascade do |t|
      t.integer  "event_id"
      t.string   "type"
      t.string   "transaction_origin"
      t.string   "action"
      t.string   "customer_tag_uid"
      t.string   "operator_tag_uid"
      t.integer  "station_id"
      t.string   "device_uid"
      t.integer  "device_db_index"
      t.string   "device_created_at"
      t.string   "device_created_at_fixed"
      t.integer  "gtag_counter"
      t.integer  "counter"
      t.integer  "activation_counter"
      t.string   "status_message"
      t.integer  "status_code"
      t.integer  "order_item_counter"
      t.integer  "access_id"
      t.integer  "direction"
      t.string   "final_access_value"
      t.string   "message"
      t.string   "ticket_code"
      t.float    "credits"
      t.float    "refundable_credits"
      t.float    "final_balance"
      t.float    "final_refundable_balance"
      t.integer  "catalog_item_id"
      t.float    "items_amount"
      t.float    "price"
      t.string   "payment_method"
      t.string   "payment_gateway"
      t.datetime "created_at",                  null: false
      t.datetime "updated_at",                  null: false
      t.integer  "ticket_id"
      t.integer  "operator_activation_counter"
      t.integer  "priority"
      t.string   "operator_value"
      t.integer  "operator_station_id"
      t.integer  "order_id"
      t.integer  "gtag_id"
      t.integer  "customer_id"
    end  unless table_exists?(:transactions)

    add_index("transactions", ["access_id"], name: "index_transactions_on_access_id", using: :btree) unless index_exists?(:transactions, :access_id)
    add_index("transactions", ["catalog_item_id"], name: "index_transactions_on_catalog_item_id", using: :btree) unless index_exists?(:transactions, :catalog_item_id)
    add_index("transactions", ["customer_id"], name: "index_transactions_on_customer_id", using: :btree) unless index_exists?(:transactions, :customer_id)
    add_index("transactions", ["event_id"], name: "index_transactions_on_event_id", using: :btree) unless index_exists?(:transactions, :event_id)
    add_index("transactions", ["gtag_id"], name: "index_transactions_on_gtag_id", using: :btree) unless index_exists?(:transactions, :gtag_id)
    add_index("transactions", ["operator_station_id"], name: "index_transactions_on_operator_station_id", using: :btree) unless index_exists?(:transactions, :operator_station_id)
    add_index("transactions", ["order_id"], name: "index_transactions_on_order_id", using: :btree) unless index_exists?(:transactions, :order_id)
    add_index("transactions", ["station_id"], name: "index_transactions_on_station_id", using: :btree) unless index_exists?(:transactions, :station_id)
    add_index("transactions", ["ticket_id"], name: "index_transactions_on_ticket_id", using: :btree) unless index_exists?(:transactions, :ticket_id)
    add_index("transactions", ["type"], name: "index_transactions_on_type", using: :btree) unless index_exists?(:transactions, :type)

    add_foreign_key("access_control_gates", "stations")
    add_foreign_key("catalog_items", "events")
    add_foreign_key("company_event_agreements", "companies")
    add_foreign_key("company_event_agreements", "events")
    add_foreign_key("customers", "events")
    add_foreign_key("device_transactions", "events")
    add_foreign_key("entitlements", "events")
    add_foreign_key("event_translations", "events")
    add_foreign_key("gtags", "customers")
    add_foreign_key("gtags", "events")
    add_foreign_key("order_items", "catalog_items")
    add_foreign_key("order_items", "orders")
    add_foreign_key("orders", "customers")
    add_foreign_key("pack_catalog_items", "catalog_items")
    add_foreign_key("payment_gateways", "events")
    add_foreign_key("products", "events")
    add_foreign_key("refunds", "customers")
    add_foreign_key("sale_items", "products")
    add_foreign_key("sale_items", "transactions", column: "credit_transaction_id")
    add_foreign_key("station_catalog_items", "catalog_items")
    add_foreign_key("station_catalog_items", "stations")
    add_foreign_key("station_products", "products")
    add_foreign_key("station_products", "stations")
    add_foreign_key("stations", "events")
    add_foreign_key("ticket_types", "catalog_items")
    add_foreign_key("ticket_types", "company_event_agreements")
    add_foreign_key("ticket_types", "events")
    add_foreign_key("tickets", "customers")
    add_foreign_key("tickets", "events")
    add_foreign_key("tickets", "ticket_types")
    add_foreign_key("topup_credits", "stations")
    add_foreign_key("transactions", "catalog_items")
    add_foreign_key("transactions", "customers")
    add_foreign_key("transactions", "events")
    add_foreign_key("transactions", "gtags")
    add_foreign_key("transactions", "orders")
    add_foreign_key("transactions", "stations")
    add_foreign_key("transactions", "tickets")
  end
end