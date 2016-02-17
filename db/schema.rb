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

ActiveRecord::Schema.define(version: 20160216123700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_entitlements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false, index: {name: "index_admins_on_email", unique: true}
    t.string   "encrypted_password",     default: "", null: false
    t.string   "access_token",           null: false
    t.string   "reset_password_token",   index: {name: "index_admins_on_reset_password_token", unique: true}
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name",                    null: false
    t.string   "aasm_state"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "slug",                    null: false, index: {name: "index_events_on_slug", unique: true}
    t.string   "location"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text     "description"
    t.string   "support_email",           default: "support@glownet.com", null: false
    t.text     "style"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "background_file_name"
    t.string   "background_content_type"
    t.integer  "background_file_size"
    t.datetime "background_updated_at"
    t.string   "url"
    t.string   "background_type",         default: "fixed"
    t.integer  "features",                default: 0,                     null: false
    t.boolean  "gtag_assignation",        default: true,                  null: false
    t.string   "payment_service",         default: "redsys"
    t.integer  "registration_parameters", default: 0,                     null: false
    t.string   "currency",                default: "USD",                 null: false
    t.string   "host_country",            default: "US",                  null: false
    t.integer  "locales",                 default: 1,                     null: false
    t.integer  "refund_services",         default: 0,                     null: false
    t.boolean  "ticket_assignation",      default: true,                  null: false
    t.string   "token"
  end

  create_table "customers", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false, index: {name: "index_customers_on_email_and_event_id", with: ["event_id"], unique: true}
    t.string   "name",                   default: "",    null: false
    t.string   "surname",                default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token",   index: {name: "index_customers_on_reset_password_token", unique: true}
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "deleted_at",             index: {name: "index_customers_on_deleted_at"}
    t.boolean  "agreed_on_registration", default: false
    t.string   "phone"
    t.string   "postcode"
    t.string   "address"
    t.string   "city"
    t.string   "country"
    t.string   "gender"
    t.datetime "birthdate"
    t.integer  "event_id",               null: false, index: {name: "fk__customers_event_id"}, foreign_key: {references: "events", name: "customers_event_id_fkey", on_update: :no_action, on_delete: :no_action}
    t.boolean  "agreed_event_condition", default: false
    t.string   "remember_token",         index: {name: "index_customers_on_remember_token", unique: true}
  end

  create_table "customer_event_profiles", force: :cascade do |t|
    t.integer  "customer_id", index: {name: "fk__customer_event_profiles_customer_id"}, foreign_key: {references: "customers", name: "customer_event_profiles_customer_id_fkey", on_update: :no_action, on_delete: :no_action}
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "event_id",    null: false, index: {name: "index_customer_event_profiles_on_event_id"}, foreign_key: {references: "events", name: "customer_event_profiles_event_id_fkey", on_update: :no_action, on_delete: :no_action}
    t.datetime "deleted_at",  index: {name: "index_customer_event_profiles_on_deleted_at"}
  end

  create_table "banned_customer_event_profiles", force: :cascade do |t|
    t.integer  "customer_event_profile_id", index: {name: "fk__banned_customer_event_profiles_customer_event_profile_id"}, foreign_key: {references: "customer_event_profiles", name: "fk_banned_customer_event_profiles_customer_event_profile_id", on_update: :no_action, on_delete: :no_action}
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "companies", force: :cascade do |t|
    t.integer  "event_id",   null: false, index: {name: "index_companies_on_event_id"}, foreign_key: {references: "events", name: "fk_companies_event_id", on_update: :no_action, on_delete: :no_action}
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "token"
    t.datetime "deleted_at", index: {name: "index_companies_on_deleted_at"}
  end

  create_table "preevent_products", force: :cascade do |t|
    t.integer  "event_id",             null: false, index: {name: "index_preevent_products_on_event_id"}, foreign_key: {references: "events", name: "fk_preevent_products_event_id", on_update: :no_action, on_delete: :no_action}
    t.string   "name"
    t.boolean  "online",               default: false, null: false
    t.integer  "initial_amount"
    t.integer  "step"
    t.integer  "max_purchasable"
    t.integer  "min_purchasable"
    t.decimal  "price"
    t.integer  "preevent_items_count", default: 0,     null: false
    t.datetime "deleted_at",           index: {name: "index_preevent_products_on_deleted_at"}
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "company_ticket_types", force: :cascade do |t|
    t.integer  "company_id",              index: {name: "fk__company_ticket_types_company_id"}, foreign_key: {references: "companies", name: "fk_company_ticket_types_company_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "preevent_product_id",     index: {name: "fk__company_ticket_types_preevent_product_id"}, foreign_key: {references: "preevent_products", name: "fk_company_ticket_types_preevent_product_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "event_id",                index: {name: "index_company_ticket_types_on_event_id"}, foreign_key: {references: "events", name: "fk_company_ticket_types_event_id", on_update: :no_action, on_delete: :no_action}
    t.string   "name"
    t.string   "company_ticket_type_ref"
    t.datetime "deleted_at",              index: {name: "index_company_ticket_types_on_deleted_at"}
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "gtags", force: :cascade do |t|
    t.string   "tag_uid",                null: false, index: {name: "index_gtags_on_tag_uid_and_event_id", with: ["event_id"], unique: true}
    t.string   "tag_serial_number"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "deleted_at",             index: {name: "index_gtags_on_deleted_at"}
    t.integer  "event_id",               null: false, index: {name: "index_gtags_on_event_id"}, foreign_key: {references: "events", name: "gtags_event_id_fkey", on_update: :no_action, on_delete: :no_action}
    t.boolean  "credential_redeemed",    default: false, null: false
    t.integer  "company_ticket_type_id", index: {name: "fk__gtags_company_ticket_type_id"}, foreign_key: {references: "company_ticket_types", name: "gtags_company_ticket_type_id_fkey", on_update: :no_action, on_delete: :no_action}
  end

  create_table "banned_gtags", force: :cascade do |t|
    t.integer  "gtag_id",    index: {name: "index_banned_gtags_on_gtag_id"}, foreign_key: {references: "gtags", name: "fk_banned_gtags_gtag_id", on_update: :no_action, on_delete: :no_action}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.string   "code",                   index: {name: "index_tickets_on_code", unique: true}
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "deleted_at",             index: {name: "index_tickets_on_deleted_at"}
    t.integer  "event_id",               null: false, index: {name: "index_tickets_on_event_id"}, foreign_key: {references: "events", name: "tickets_event_id_fkey", on_update: :no_action, on_delete: :no_action}
    t.boolean  "credential_redeemed",    default: false, null: false
    t.integer  "company_ticket_type_id", index: {name: "fk__tickets_company_ticket_type_id"}, foreign_key: {references: "company_ticket_types", name: "tickets_company_ticket_type_id_fkey", on_update: :no_action, on_delete: :no_action}
  end

  create_table "banned_tickets", force: :cascade do |t|
    t.integer  "ticket_id",  index: {name: "index_banned_tickets_on_ticket_id"}, foreign_key: {references: "tickets", name: "fk_banned_tickets_ticket_id", on_update: :no_action, on_delete: :no_action}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "claims", force: :cascade do |t|
    t.string   "number",                    null: false, index: {name: "index_claims_on_number", unique: true}
    t.string   "aasm_state",                null: false
    t.datetime "completed_at"
    t.decimal  "total",                     precision: 8, scale: 2,               null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "gtag_id",                   index: {name: "index_claims_on_gtag_id"}, foreign_key: {references: "gtags", name: "claims_gtag_id_fkey", on_update: :no_action, on_delete: :no_action}
    t.string   "service_type"
    t.decimal  "fee",                       precision: 8, scale: 2, default: 0.0
    t.decimal  "minimum",                   precision: 8, scale: 2, default: 0.0
    t.integer  "customer_event_profile_id", index: {name: "index_claims_on_customer_event_profile_id"}, foreign_key: {references: "customer_event_profiles", name: "claims_customer_event_profile_id_fkey", on_update: :no_action, on_delete: :no_action}
  end

  create_table "parameters", force: :cascade do |t|
    t.string   "name",        null: false, index: {name: "index_parameters_on_name_and_group_and_category", with: ["group", "category"], unique: true}
    t.string   "data_type",   null: false
    t.string   "category",    null: false
    t.string   "group",       null: false
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "claim_parameters", force: :cascade do |t|
    t.string   "value",        default: "", null: false
    t.integer  "claim_id",     null: false, index: {name: "index_claim_parameters_on_claim_id"}, foreign_key: {references: "claims", name: "fk_claim_parameters_claim_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "parameter_id", null: false, index: {name: "index_claim_parameters_on_parameter_id"}, foreign_key: {references: "parameters", name: "fk_claim_parameters_parameter_id", on_update: :no_action, on_delete: :no_action}
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id",   null: false
    t.string   "commentable_type", null: false
    t.integer  "admin_id",         index: {name: "fk__comments_admin_id"}, foreign_key: {references: "admins", name: "fk_comments_admin_id", on_update: :no_action, on_delete: :no_action}
    t.text     "body"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "credential_assignments", force: :cascade do |t|
    t.integer  "customer_event_profile_id", null: false, index: {name: "fk__credential_assignments_customer_event_profile_id"}, foreign_key: {references: "customer_event_profiles", name: "fk_credential_assignments_customer_event_profile_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "credentiable_id",           null: false
    t.string   "credentiable_type",         null: false
    t.string   "aasm_state"
    t.datetime "deleted_at",                index: {name: "index_credential_assignments_on_deleted_at"}
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "credential_types", force: :cascade do |t|
    t.integer  "memory_position", null: false
    t.datetime "deleted_at",      index: {name: "index_credential_types_on_deleted_at"}
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "credit_logs", force: :cascade do |t|
    t.string   "transaction_type"
    t.decimal  "amount",                    precision: 8, scale: 2, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "customer_event_profile_id", index: {name: "index_credit_logs_on_customer_event_profile_id"}, foreign_key: {references: "customer_event_profiles", name: "credit_logs_customer_event_profile_id_fkey", on_update: :no_action, on_delete: :no_action}
  end

  create_table "credits", force: :cascade do |t|
    t.boolean  "standard",   default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at", index: {name: "index_credits_on_deleted_at"}
    t.decimal  "value",      precision: 8, scale: 2, default: 1.0,   null: false
    t.string   "currency"
  end

  create_table "customer_orders", force: :cascade do |t|
    t.integer  "preevent_product_id",       null: false, index: {name: "fk__customer_orders_preevent_product_id"}, foreign_key: {references: "preevent_products", name: "fk_customer_orders_preevent_product_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "customer_event_profile_id", null: false, index: {name: "fk__customer_orders_customer_event_profile_id"}, foreign_key: {references: "customer_event_profiles", name: "fk_customer_orders_customer_event_profile_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "counter"
    t.string   "aasm_state",                default: "unredeemed", null: false
    t.datetime "deleted_at",                index: {name: "index_customer_orders_on_deleted_at"}
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "devices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_parameters", force: :cascade do |t|
    t.string   "value",        default: "", null: false
    t.integer  "event_id",     null: false, index: {name: "index_event_parameters_on_event_id"}, foreign_key: {references: "events", name: "fk_event_parameters_event_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "parameter_id", null: false, index: {name: "index_event_parameters_on_parameter_id"}, foreign_key: {references: "parameters", name: "fk_event_parameters_parameter_id", on_update: :no_action, on_delete: :no_action}
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end
  add_index "event_parameters", ["event_id", "parameter_id"], name: "index_event_parameters_on_event_id_and_parameter_id", unique: true

  create_table "event_translations", force: :cascade do |t|
    t.integer  "event_id",                       null: false, index: {name: "fk__event_translations_event_id"}, foreign_key: {references: "events", name: "fk_event_translations_event_id", on_update: :no_action, on_delete: :no_action}
    t.string   "locale",                         null: false, index: {name: "index_event_translations_on_locale"}
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "info"
    t.text     "disclaimer"
    t.text     "refund_success_message"
    t.text     "mass_email_claim_notification"
    t.text     "gtag_assignation_notification"
    t.text     "gtag_form_disclaimer"
    t.string   "gtag_name"
    t.text     "agreed_event_condition_message"
    t.text     "refund_disclaimer"
    t.text     "bank_account_disclaimer"
  end
  add_index "event_translations", ["event_id"], name: "index_event_translations_on_event_id"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           null: false, index: {name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", with: ["sluggable_type", "scope"], unique: true}
    t.integer  "sluggable_id",   null: false, index: {name: "index_friendly_id_slugs_on_sluggable_id"}
    t.string   "sluggable_type", limit: 50, index: {name: "index_friendly_id_slugs_on_sluggable_type"}
    t.string   "scope"
    t.datetime "created_at"
  end
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"

  create_table "gtag_credit_logs", force: :cascade do |t|
    t.integer  "gtag_id",    null: false, index: {name: "fk__gtag_credit_logs_gtag_id"}, foreign_key: {references: "gtags", name: "fk_gtag_credit_logs_gtag_id", on_update: :no_action, on_delete: :no_action}
    t.decimal  "amount",     precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string   "number",                    null: false, index: {name: "index_orders_on_number", unique: true}
    t.string   "aasm_state",                null: false
    t.datetime "completed_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "customer_event_profile_id", index: {name: "index_orders_on_customer_event_profile_id"}, foreign_key: {references: "customer_event_profiles", name: "orders_customer_event_profile_id_fkey", on_update: :no_action, on_delete: :no_action}
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id",            null: false, index: {name: "fk__order_items_order_id"}, foreign_key: {references: "orders", name: "fk_order_items_order_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "amount"
    t.decimal  "total",               precision: 8, scale: 2, null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "preevent_product_id", index: {name: "fk__order_items_preevent_product_id"}, foreign_key: {references: "preevent_products", name: "order_items_preevent_product_id_fkey", on_update: :no_action, on_delete: :no_action}
  end

  create_table "payment_gateway_customers", force: :cascade do |t|
    t.integer  "customer_event_profile_id", index: {name: "fk__payment_gateway_customers_customer_event_profile_id"}, foreign_key: {references: "customer_event_profiles", name: "fk_payment_gateway_customers_customer_event_profile_id", on_update: :no_action, on_delete: :no_action}
    t.string   "token",                     index: {name: "index_payment_gateway_customers_on_token_and_gateway_type", with: ["gateway_type"], unique: true}
    t.string   "gateway_type",              index: {name: "index_payment_gateway_customers_on_gateway_type"}
    t.datetime "deleted_at",                index: {name: "index_payment_gateway_customers_on_deleted_at"}
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "order_id",           null: false, index: {name: "fk__payments_order_id"}, foreign_key: {references: "orders", name: "fk_payments_order_id", on_update: :no_action, on_delete: :no_action}
    t.decimal  "amount",             precision: 8, scale: 2, null: false
    t.string   "terminal"
    t.string   "transaction_type"
    t.string   "card_country"
    t.string   "response_code"
    t.string   "authorization_code"
    t.string   "currency"
    t.string   "merchant_code"
    t.boolean  "success"
    t.string   "payment_type"
    t.datetime "paid_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "last4"
  end

  create_table "preevent_items", force: :cascade do |t|
    t.integer  "purchasable_id",   null: false
    t.string   "purchasable_type", null: false
    t.integer  "event_id",         index: {name: "index_preevent_items_on_event_id"}, foreign_key: {references: "events", name: "fk_preevent_items_event_id", on_update: :no_action, on_delete: :no_action}
    t.string   "name"
    t.text     "description"
    t.datetime "deleted_at",       index: {name: "index_preevent_items_on_deleted_at"}
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "preevent_product_items", force: :cascade do |t|
    t.integer  "preevent_item_id",     index: {name: "fk__preevent_product_items_preevent_item_id"}, foreign_key: {references: "preevent_items", name: "fk_preevent_product_items_preevent_item_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "preevent_product_id",  index: {name: "fk__preevent_product_items_preevent_product_id"}, foreign_key: {references: "preevent_products", name: "fk_preevent_product_items_preevent_product_id", on_update: :no_action, on_delete: :no_action}
    t.decimal  "amount",               precision: 8, scale: 2, default: 1.0, null: false
    t.integer  "preevent_items_count", default: 0,   null: false
    t.datetime "deleted_at",           index: {name: "index_preevent_product_items_on_deleted_at"}
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "purchasers", force: :cascade do |t|
    t.integer  "credentiable_id",       null: false
    t.string   "credentiable_type",     null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "gtag_delivery_address"
    t.datetime "deleted_at",            index: {name: "index_purchasers_on_deleted_at"}
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "refunds", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "claim_id",                   index: {name: "index_refunds_on_claim_id"}, foreign_key: {references: "claims", name: "refunds_claim_id_fkey", on_update: :no_action, on_delete: :no_action}
    t.decimal  "amount",                     precision: 8, scale: 2, null: false
    t.string   "currency"
    t.string   "message"
    t.string   "operation_type"
    t.string   "gateway_transaction_number"
    t.string   "payment_solution"
    t.string   "status"
  end

  create_table "stations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "ticket_blacklists", force: :cascade do |t|
    t.integer  "ticket_id",  index: {name: "index_ticket_blacklists_on_ticket_id"}, foreign_key: {references: "tickets", name: "fk_ticket_blacklists_ticket_id", on_update: :no_action, on_delete: :no_action}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string   "type",                      null: false
    t.integer  "event_id",                  index: {name: "fk__transactions_event_id"}, foreign_key: {references: "events", name: "fk_transactions_event_id", on_update: :no_action, on_delete: :no_action}
    t.string   "transaction_type"
    t.datetime "device_created_at"
    t.integer  "ticket_id",                 index: {name: "fk__transactions_ticket_id"}, foreign_key: {references: "tickets", name: "fk_transactions_ticket_id", on_update: :no_action, on_delete: :no_action}
    t.string   "customer_tag_uid"
    t.string   "operator_tag_uid"
    t.integer  "station_id",                index: {name: "fk__transactions_station_id"}, foreign_key: {references: "stations", name: "fk_transactions_station_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "device_id",                 index: {name: "fk__transactions_device_id"}, foreign_key: {references: "devices", name: "fk_transactions_device_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "device_uid"
    t.integer  "preevent_product_id",       index: {name: "fk__transactions_preevent_product_id"}, foreign_key: {references: "preevent_products", name: "fk_transactions_preevent_product_id", on_update: :no_action, on_delete: :no_action}
    t.integer  "customer_event_profile_id", index: {name: "fk__transactions_customer_event_profile_id"}, foreign_key: {references: "customer_event_profiles", name: "fk_transactions_customer_event_profile_id", on_update: :no_action, on_delete: :no_action}
    t.string   "payment_method"
    t.string   "status_code"
    t.string   "status_message"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "credits"
    t.integer  "credits_refundable"
    t.integer  "value_credit"
    t.string   "payment_gateway"
    t.integer  "final_balance"
    t.integer  "final_refundable_balance"
    t.integer  "access_entitlement_id",     index: {name: "index_transactions_on_access_entitlement_id"}, foreign_key: {references: "access_entitlements", name: "transactions_access_entitlement_id_fkey", on_update: :no_action, on_delete: :no_action}
    t.integer  "direction"
    t.integer  "access_entitlement_value"
  end

  create_table "vouchers", force: :cascade do |t|
    t.datetime "deleted_at", index: {name: "index_vouchers_on_deleted_at"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
