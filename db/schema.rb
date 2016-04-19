# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160604131100) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_control_gates", force: :cascade do |t|
    t.integer  "access_id",  null: false
    t.string   "direction",  null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "access_transactions", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "transaction_origin"
    t.string   "customer_tag_uid"
    t.string   "transaction_type"
    t.integer  "station_id"
    t.integer  "device_db_index"
    t.string   "device_created_at"
    t.integer  "customer_event_profile_id"
    t.integer  "access_id"
    t.integer  "direction"
    t.string   "final_access_value"
    t.integer  "status_code"
    t.string   "status_message"
    t.string   "device_uid"
    t.string   "operator_tag_uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_transactions", ["access_id"], name: "index_access_transactions_on_access_id", using: :btree
  add_index "access_transactions", ["customer_event_profile_id"], name: "index_access_transactions_on_customer_event_profile_id", using: :btree
  add_index "access_transactions", ["event_id"], name: "index_access_transactions_on_event_id", using: :btree
  add_index "access_transactions", ["station_id"], name: "index_access_transactions_on_station_id", using: :btree

  create_table "accesses", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "accesses", ["deleted_at"], name: "index_accesses_on_deleted_at", using: :btree

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
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "banned_customer_event_profiles", force: :cascade do |t|
    t.integer  "customer_event_profile_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "banned_customer_event_profiles", ["deleted_at"], name: "index_banned_customer_event_profiles_on_deleted_at", using: :btree

  create_table "banned_gtags", force: :cascade do |t|
    t.integer  "gtag_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "banned_tickets", force: :cascade do |t|
    t.integer  "ticket_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "banned_tickets", ["deleted_at"], name: "index_banned_tickets_on_deleted_at", using: :btree

  create_table "c_assignments_c_orders", force: :cascade do |t|
    t.integer "credential_assignment_id"
    t.integer "customer_order_id"
  end

  add_index "c_assignments_c_orders", ["credential_assignment_id"], name: "index_c_assignments_c_orders_on_credential_assignment_id", using: :btree
  add_index "c_assignments_c_orders", ["customer_order_id"], name: "index_c_assignments_c_orders_on_customer_order_id", using: :btree

  create_table "catalog_items", force: :cascade do |t|
    t.integer  "event_id",         null: false
    t.integer  "catalogable_id",   null: false
    t.string   "catalogable_type", null: false
    t.string   "name"
    t.text     "description"
    t.integer  "initial_amount"
    t.integer  "step"
    t.integer  "max_purchasable"
    t.integer  "min_purchasable"
    t.datetime "deleted_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "catalog_items", ["deleted_at"], name: "index_catalog_items_on_deleted_at", using: :btree
  add_index "catalog_items", ["event_id"], name: "index_catalog_items_on_event_id", using: :btree

  create_table "claim_parameters", force: :cascade do |t|
    t.string   "value",        default: "", null: false
    t.integer  "claim_id",                  null: false
    t.integer  "parameter_id",              null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "claims", force: :cascade do |t|
    t.integer  "customer_event_profile_id",                                       null: false
    t.integer  "gtag_id",                                                         null: false
    t.string   "number",                                                          null: false
    t.string   "aasm_state",                                                      null: false
    t.decimal  "total",                     precision: 8, scale: 2,               null: false
    t.string   "service_type"
    t.decimal  "fee",                       precision: 8, scale: 2, default: 0.0
    t.decimal  "minimum",                   precision: 8, scale: 2, default: 0.0
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
  end

  add_index "claims", ["deleted_at"], name: "index_claims_on_deleted_at", using: :btree
  add_index "claims", ["number"], name: "index_claims_on_number", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id",   null: false
    t.string   "commentable_type", null: false
    t.integer  "admin_id",         null: false
    t.text     "body"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "access_token"
    t.datetime "deleted_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "companies", ["deleted_at"], name: "index_companies_on_deleted_at", using: :btree

  create_table "company_event_agreements", force: :cascade do |t|
    t.integer  "company_id", null: false
    t.integer  "event_id",   null: false
    t.string   "aasm_state"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "company_event_agreements", ["deleted_at"], name: "index_company_event_agreements_on_deleted_at", using: :btree

  create_table "company_ticket_types", force: :cascade do |t|
    t.integer  "event_id",                   null: false
    t.integer  "company_event_agreement_id", null: false
    t.integer  "credential_type_id"
    t.string   "name"
    t.string   "company_code"
    t.datetime "deleted_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "company_ticket_types", ["company_code", "company_event_agreement_id"], name: "company_ref_event_agreement_index", unique: true, using: :btree
  add_index "company_ticket_types", ["deleted_at"], name: "index_company_ticket_types_on_deleted_at", using: :btree

  create_table "credential_assignments", force: :cascade do |t|
    t.integer  "customer_event_profile_id"
    t.integer  "credentiable_id",           null: false
    t.string   "credentiable_type",         null: false
    t.string   "aasm_state"
    t.datetime "deleted_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "credential_transactions", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "transaction_origin"
    t.string   "transaction_category"
    t.string   "transaction_type"
    t.string   "customer_tag_uid"
    t.string   "operator_tag_uid"
    t.integer  "station_id"
    t.string   "device_uid"
    t.integer  "device_db_index"
    t.datetime "device_created_at"
    t.integer  "ticket_id"
    t.integer  "customer_event_profile_id"
    t.integer  "status_code"
    t.string   "status_message"
    t.string   "ticket_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credential_transactions", ["customer_event_profile_id"], name: "index_credential_transactions_on_customer_event_profile_id", using: :btree
  add_index "credential_transactions", ["event_id"], name: "index_credential_transactions_on_event_id", using: :btree
  add_index "credential_transactions", ["station_id"], name: "index_credential_transactions_on_station_id", using: :btree
  add_index "credential_transactions", ["ticket_id"], name: "index_credential_transactions_on_ticket_id", using: :btree

  create_table "credential_types", force: :cascade do |t|
    t.integer  "catalog_item_id", null: false
    t.integer  "memory_position", null: false
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "credential_types", ["deleted_at"], name: "index_credential_types_on_deleted_at", using: :btree

  create_table "credit_transactions", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "transaction_origin"
    t.string   "transaction_category"
    t.string   "transaction_type"
    t.string   "customer_tag_uid"
    t.string   "operator_tag_uid"
    t.integer  "station_id"
    t.string   "device_uid"
    t.integer  "device_db_index"
    t.datetime "device_created_at"
    t.float    "credits"
    t.float    "credits_refundable"
    t.float    "credit_value"
    t.float    "final_balance"
    t.float    "final_refundable_balance"
    t.integer  "customer_event_profile_id"
    t.integer  "status_code"
    t.string   "status_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_transactions", ["customer_event_profile_id"], name: "index_credit_transactions_on_customer_event_profile_id", using: :btree
  add_index "credit_transactions", ["event_id"], name: "index_credit_transactions_on_event_id", using: :btree
  add_index "credit_transactions", ["station_id"], name: "index_credit_transactions_on_station_id", using: :btree

  create_table "credits", force: :cascade do |t|
    t.boolean  "standard",                           default: false, null: false
    t.decimal  "value",      precision: 8, scale: 2, default: 1.0,   null: false
    t.string   "currency"
    t.datetime "deleted_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "credits", ["deleted_at"], name: "index_credits_on_deleted_at", using: :btree

  create_table "customer_credits", force: :cascade do |t|
    t.integer  "customer_event_profile_id",                                       null: false
    t.string   "transaction_origin",                                              null: false
    t.string   "payment_method",                                                  null: false
    t.decimal  "amount",                    precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "refundable_amount",         precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "final_balance",             precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "final_refundable_balance",  precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "credit_value",              precision: 8, scale: 2, default: 1.0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.datetime "created_in_origin_at"
  end

  add_index "customer_credits", ["deleted_at"], name: "index_customer_credits_on_deleted_at", using: :btree

  create_table "customer_event_profiles", force: :cascade do |t|
    t.integer  "customer_id"
    t.integer  "event_id",    null: false
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "customer_event_profiles", ["deleted_at"], name: "index_customer_event_profiles_on_deleted_at", using: :btree

  create_table "customer_orders", force: :cascade do |t|
    t.integer  "customer_event_profile_id", null: false
    t.integer  "catalog_item_id",           null: false
    t.string   "origin"
    t.integer  "amount"
    t.datetime "deleted_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "customer_orders", ["deleted_at"], name: "index_customer_orders_on_deleted_at", using: :btree

  create_table "customers", force: :cascade do |t|
    t.integer  "event_id",                               null: false
    t.string   "email",                  default: "",    null: false
    t.string   "first_name",             default: "",    null: false
    t.string   "last_name",              default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.string   "phone"
    t.string   "postcode"
    t.string   "address"
    t.string   "city"
    t.string   "country"
    t.string   "gender"
    t.string   "remember_token"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.boolean  "agreed_on_registration", default: false
    t.boolean  "agreed_event_condition", default: false
    t.inet     "last_sign_in_ip"
    t.inet     "current_sign_in_ip"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.datetime "birthdate"
    t.datetime "deleted_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "customers", ["deleted_at", "email", "event_id"], name: "index_customers_on_deleted_at_and_email_and_event_id", unique: true, using: :btree
  add_index "customers", ["deleted_at"], name: "index_customers_on_deleted_at", using: :btree
  add_index "customers", ["remember_token"], name: "index_customers_on_remember_token", unique: true, using: :btree
  add_index "customers", ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true, using: :btree

  create_table "entitlements", force: :cascade do |t|
    t.integer  "entitlementable_id",                   null: false
    t.string   "entitlementable_type",                 null: false
    t.integer  "event_id",                             null: false
    t.integer  "memory_position",                      null: false
    t.boolean  "infinite",             default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "memory_length",        default: 1
  end

  add_index "entitlements", ["deleted_at"], name: "index_entitlements_on_deleted_at", using: :btree

  create_table "event_parameters", force: :cascade do |t|
    t.string   "value",        default: "", null: false
    t.integer  "event_id",                  null: false
    t.integer  "parameter_id",              null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "event_parameters", ["event_id", "parameter_id"], name: "index_event_parameters_on_event_id_and_parameter_id", unique: true, using: :btree

  create_table "event_translations", force: :cascade do |t|
    t.integer  "event_id",                       null: false
    t.string   "locale",                         null: false
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
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "event_translations", ["locale"], name: "index_event_translations_on_locale", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",                                                    null: false
    t.string   "aasm_state"
    t.string   "slug",                                                    null: false
    t.string   "location"
    t.string   "support_email",           default: "support@glownet.com", null: false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.string   "background_file_name"
    t.string   "background_content_type"
    t.string   "url"
    t.string   "background_type",         default: "fixed"
    t.string   "currency",                default: "USD",                 null: false
    t.string   "host_country",            default: "US",                  null: false
    t.string   "token"
    t.text     "description"
    t.text     "style"
    t.integer  "logo_file_size"
    t.integer  "background_file_size"
    t.integer  "features",                default: 0,                     null: false
    t.integer  "registration_parameters", default: 0,                     null: false
    t.integer  "locales",                 default: 1,                     null: false
    t.integer  "payment_services",        default: 0,                     null: false
    t.integer  "refund_services",         default: 0,                     null: false
    t.boolean  "gtag_assignation",        default: true,                  null: false
    t.boolean  "ticket_assignation",      default: true,                  null: false
    t.datetime "logo_updated_at"
    t.datetime "background_updated_at"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "token_symbol",            default: "t"
    t.string   "company_name"
  end

  add_index "events", ["slug"], name: "index_events_on_slug", unique: true, using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "gtags", force: :cascade do |t|
    t.integer  "event_id",                               null: false
    t.integer  "company_ticket_type_id"
    t.string   "tag_serial_number"
    t.string   "tag_uid",                                null: false
    t.boolean  "credential_redeemed",    default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "gtags", ["deleted_at", "tag_uid", "event_id"], name: "index_gtags_on_deleted_at_and_tag_uid_and_event_id", unique: true, using: :btree
  add_index "gtags", ["deleted_at"], name: "index_gtags_on_deleted_at", using: :btree

  create_table "money_transactions", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "transaction_origin"
    t.string   "transaction_category"
    t.string   "transaction_type"
    t.string   "customer_tag_uid"
    t.string   "operator_tag_uid"
    t.integer  "station_id"
    t.string   "device_uid"
    t.integer  "device_db_index"
    t.datetime "device_created_at"
    t.integer  "catalogable_id"
    t.string   "catalogable_type"
    t.integer  "items_amount"
    t.float    "price"
    t.string   "payment_method"
    t.string   "payment_gateway"
    t.integer  "customer_event_profile_id"
    t.integer  "status_code"
    t.string   "status_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "money_transactions", ["customer_event_profile_id"], name: "index_money_transactions_on_customer_event_profile_id", using: :btree
  add_index "money_transactions", ["event_id"], name: "index_money_transactions_on_event_id", using: :btree
  add_index "money_transactions", ["station_id"], name: "index_money_transactions_on_station_id", using: :btree

  create_table "online_orders", force: :cascade do |t|
    t.integer  "customer_order_id", null: false
    t.integer  "counter"
    t.boolean  "redeemed"
    t.datetime "deleted_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "online_orders", ["deleted_at"], name: "index_online_orders_on_deleted_at", using: :btree

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id",                                null: false
    t.integer  "catalog_item_id",                         null: false
    t.integer  "amount"
    t.decimal  "total",           precision: 8, scale: 2, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "order_items", ["deleted_at"], name: "index_order_items_on_deleted_at", using: :btree

  create_table "order_transactions", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "transaction_origin"
    t.string   "transaction_category"
    t.string   "transaction_type"
    t.string   "customer_tag_uid"
    t.string   "operator_tag_uid"
    t.integer  "station_id"
    t.string   "device_uid"
    t.integer  "device_db_index"
    t.string   "device_created_at"
    t.integer  "customer_order_id"
    t.integer  "customer_event_profile_id"
    t.string   "status_message"
    t.integer  "status_code"
    t.string   "catalogable_type"
    t.integer  "catalogable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_transactions", ["customer_event_profile_id"], name: "index_order_transactions_on_customer_event_profile_id", using: :btree
  add_index "order_transactions", ["customer_order_id"], name: "index_order_transactions_on_customer_order_id", using: :btree
  add_index "order_transactions", ["event_id"], name: "index_order_transactions_on_event_id", using: :btree
  add_index "order_transactions", ["station_id"], name: "index_order_transactions_on_station_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "number",                    null: false
    t.string   "aasm_state",                null: false
    t.integer  "customer_event_profile_id"
    t.datetime "completed_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "orders", ["customer_event_profile_id"], name: "index_orders_on_customer_event_profile_id", using: :btree
  add_index "orders", ["deleted_at"], name: "index_orders_on_deleted_at", using: :btree
  add_index "orders", ["number"], name: "index_orders_on_number", unique: true, using: :btree

  create_table "pack_catalog_items", force: :cascade do |t|
    t.integer  "pack_id",         null: false
    t.integer  "catalog_item_id", null: false
    t.integer  "amount"
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pack_catalog_items", ["catalog_item_id"], name: "index_pack_catalog_items_on_catalog_item_id", using: :btree
  add_index "pack_catalog_items", ["deleted_at"], name: "index_pack_catalog_items_on_deleted_at", using: :btree
  add_index "pack_catalog_items", ["pack_id"], name: "index_pack_catalog_items_on_pack_id", using: :btree

  create_table "packs", force: :cascade do |t|
    t.integer  "catalog_items_count", default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "packs", ["deleted_at"], name: "index_packs_on_deleted_at", using: :btree

  create_table "parameters", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "category",    null: false
    t.string   "group",       null: false
    t.string   "data_type",   null: false
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "parameters", ["name", "group", "category"], name: "index_parameters_on_name_and_group_and_category", unique: true, using: :btree

  create_table "payment_gateway_customers", force: :cascade do |t|
    t.integer  "customer_event_profile_id"
    t.string   "token"
    t.string   "gateway_type"
    t.datetime "deleted_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "agreement_accepted",        default: false, null: false
    t.integer  "autotopup_amount"
    t.string   "email"
  end

  add_index "payment_gateway_customers", ["deleted_at"], name: "index_payment_gateway_customers_on_deleted_at", using: :btree
  add_index "payment_gateway_customers", ["gateway_type"], name: "index_payment_gateway_customers_on_gateway_type", using: :btree
  add_index "payment_gateway_customers", ["token", "gateway_type"], name: "index_payment_gateway_customers_on_token_and_gateway_type", unique: true, using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "order_id",                                   null: false
    t.decimal  "amount",             precision: 8, scale: 2, null: false
    t.string   "terminal"
    t.string   "transaction_type"
    t.string   "card_country"
    t.string   "response_code"
    t.string   "authorization_code"
    t.string   "currency"
    t.string   "merchant_code"
    t.string   "payment_type"
    t.string   "last4"
    t.boolean  "success"
    t.datetime "paid_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.boolean  "is_alcohol",  default: false
    t.datetime "deleted_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "description"
    t.integer  "event_id"
  end

  add_index "products", ["deleted_at"], name: "index_products_on_deleted_at", using: :btree

  create_table "products_vouchers", force: :cascade do |t|
    t.integer "product_id"
    t.integer "voucher_id"
  end

  add_index "products_vouchers", ["product_id"], name: "index_products_vouchers_on_product_id", using: :btree
  add_index "products_vouchers", ["voucher_id"], name: "index_products_vouchers_on_voucher_id", using: :btree

  create_table "purchasers", force: :cascade do |t|
    t.integer  "credentiable_id",       null: false
    t.string   "credentiable_type",     null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "gtag_delivery_address"
    t.datetime "deleted_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "purchasers", ["deleted_at"], name: "index_purchasers_on_deleted_at", using: :btree

  create_table "refunds", force: :cascade do |t|
    t.integer  "claim_id",                                           null: false
    t.decimal  "amount",                     precision: 8, scale: 2, null: false
    t.string   "currency"
    t.string   "message"
    t.string   "operation_type"
    t.string   "gateway_transaction_number"
    t.string   "payment_solution"
    t.string   "status"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "sale_items", force: :cascade do |t|
    t.integer "product_id"
    t.integer "quantity"
    t.float   "unit_price"
    t.integer "credit_transaction_id"
  end

  create_table "station_catalog_items", force: :cascade do |t|
    t.integer  "catalog_item_id", null: false
    t.float    "price",           null: false
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "station_groups", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "icon_slug",  null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "station_groups", ["deleted_at"], name: "index_station_groups_on_deleted_at", using: :btree
  add_index "station_groups", ["name"], name: "index_station_groups_on_name", using: :btree

  create_table "station_parameters", force: :cascade do |t|
    t.integer  "station_id",               null: false
    t.integer  "station_parametable_id",   null: false
    t.string   "station_parametable_type", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "station_products", force: :cascade do |t|
    t.integer  "product_id", null: false
    t.float    "price",      null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "station_types", force: :cascade do |t|
    t.integer  "station_group_id", null: false
    t.string   "name",             null: false
    t.string   "environment",      null: false
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "station_types", ["deleted_at"], name: "index_station_types_on_deleted_at", using: :btree
  add_index "station_types", ["name"], name: "index_station_types_on_name", using: :btree

  create_table "stations", force: :cascade do |t|
    t.integer  "event_id",        null: false
    t.integer  "station_type_id", null: false
    t.string   "name",            null: false
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "location"
  end

  add_index "stations", ["deleted_at"], name: "index_stations_on_deleted_at", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.integer  "event_id",                               null: false
    t.integer  "company_ticket_type_id",                 null: false
    t.string   "code"
    t.boolean  "credential_redeemed",    default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "tickets", ["deleted_at", "code", "event_id"], name: "index_tickets_on_deleted_at_and_code_and_event_id", unique: true, using: :btree
  add_index "tickets", ["deleted_at"], name: "index_tickets_on_deleted_at", using: :btree

  create_table "topup_credits", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "credit_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "topup_credits", ["credit_id"], name: "index_topup_credits_on_credit_id", using: :btree

  create_table "vouchers", force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "vouchers", ["deleted_at"], name: "index_vouchers_on_deleted_at", using: :btree

  add_foreign_key "access_transactions", "customer_event_profiles"
  add_foreign_key "access_transactions", "events"
  add_foreign_key "access_transactions", "stations"
  add_foreign_key "credential_transactions", "customer_event_profiles"
  add_foreign_key "credential_transactions", "events"
  add_foreign_key "credential_transactions", "stations"
  add_foreign_key "credential_transactions", "tickets"
  add_foreign_key "credit_transactions", "customer_event_profiles"
  add_foreign_key "credit_transactions", "events"
  add_foreign_key "credit_transactions", "stations"
  add_foreign_key "money_transactions", "customer_event_profiles"
  add_foreign_key "money_transactions", "events"
  add_foreign_key "money_transactions", "stations"
  add_foreign_key "order_transactions", "customer_event_profiles"
  add_foreign_key "order_transactions", "customer_orders"
  add_foreign_key "order_transactions", "events"
  add_foreign_key "order_transactions", "stations"
  add_foreign_key "topup_credits", "credits"
end
