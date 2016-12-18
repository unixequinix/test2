class InitialDatabase < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string   :name,                                                         null: false
      t.string   :aasm_state
      t.string   :slug,                                                         null: false
      t.string   :location
      t.string   :support_email,                default: "support@glownet.com", null: false
      t.string   :logo_file_name
      t.string   :logo_content_type
      t.string   :background_file_name
      t.string   :background_content_type
      t.string   :url
      t.string   :background_type,              default: :fixed
      t.string   :currency,                     default: :USD,                 null: false
      t.string   :host_country,                 default: :US,                  null: false
      t.string   :token
      t.text     :style
      t.integer  :logo_file_size
      t.integer  :background_file_size
      t.datetime :logo_updated_at
      t.datetime :background_updated_at
      t.datetime :start_date
      t.datetime :end_date
      t.string   :token_symbol,                 default: :t
      t.string   :company_name
      t.string   :device_full_db_file_name
      t.string   :device_full_db_content_type
      t.integer  :device_full_db_file_size
      t.datetime :device_full_db_updated_at
      t.string   :device_basic_db_file_name
      t.string   :device_basic_db_content_type
      t.integer  :device_basic_db_file_size
      t.datetime :device_basic_db_updated_at
      t.string   :official_address
      t.string   :registration_num
      t.string   :official_name
      t.string   :eventbrite_token
      t.string   :eventbrite_event
      t.string   :eventbrite_client_key
      t.string   :eventbrite_client_secret
      t.boolean  :ticket_assignation,           default: false
      t.boolean  :gtag_assignation,             default: false
      t.json     :registration_settings
      t.json     :gtag_settings
      t.json     :device_settings
      t.string   :timezone
      t.timestamps
    end  unless table_exists?(:events)
    add_index(:events, [:slug], name: :index_events_on_slug, unique: true, using: :btree) unless index_exists?(:events, :slug)

    create_table :stations do |t|
      t.references :event, index: true, foreign_key: true
      t.string   :name,                               null: false
      t.string   :location,           default:""
      t.integer  :position
      t.string   :group
      t.string   :category
      t.string   :reporting_category
      t.string   :address
      t.string   :registration_num
      t.string   :official_name
      t.integer :station_event_id
      t.boolean  :hidden,             default: false
      t.timestamps
    end  unless table_exists?(:stations)

    create_table :access_control_gates do |t|
      t.references :access, index: true
      t.string     :direction,                  null: false
      t.boolean    :hidden
      t.references :station, index: true, foreign_key: true
      t.timestamps
    end  unless table_exists?(:access_control_gates)

    create_table :admins do |t|
      t.string   :email,                  default:"", null: false
      t.string   :encrypted_password,     default:"", null: false
      t.string   :access_token,                       null: false
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count,          default: 0,  null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip
      t.timestamps
    end  unless table_exists?(:admins)
    add_index(:admins, [:email], name: :index_admins_on_email, unique: true, using: :btree) unless index_exists?(:admins, :email)
    add_index(:admins, [:reset_password_token], name: :index_admins_on_reset_password_token, unique: true, using: :btree) unless index_exists?(:admins, :reset_password_token)

    create_table :catalog_items do |t|
      t.references  :event, index: true, foreign_key: true
      t.string   :type,                                                  null: false
      t.string   :name
      t.integer  :initial_amount
      t.integer  :step
      t.integer  :max_purchasable
      t.integer  :min_purchasable
      t.decimal  :value,           precision: 8, scale: 2, default: 1.0, null: false
      t.timestamps
    end  unless table_exists?(:catalog_items)

    create_table :companies do |t|
      t.string   :name,         null: false
      t.string   :access_token
      t.timestamps
    end  unless table_exists?(:companies)

    create_table :company_event_agreements do |t|
      t.references :company, index: true, foreign_key: true
      t.references :event, index: true, foreign_key: true
      t.string   :aasm_state
      t.timestamps
    end  unless table_exists?(:company_event_agreements)

    create_table :customers do |t|
      t.references :event, index: true, foreign_key: true
      t.string   :email,                      default:"",     null: false
      t.string   :first_name,                 default:"",     null: false
      t.string   :last_name,                  default:"",     null: false
      t.string   :encrypted_password,         default:"",     null: false
      t.string   :reset_password_token
      t.string   :phone
      t.string   :postcode
      t.string   :address
      t.string   :city
      t.string   :country
      t.string   :gender
      t.string   :remember_token
      t.integer  :sign_in_count,              default: 0,     null: false
      t.boolean  :agreed_on_registration,     default: false
      t.boolean  :agreed_event_condition,     default: false
      t.inet     :last_sign_in_ip
      t.inet     :current_sign_in_ip
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.datetime :birthdate
      t.boolean  :receive_communications,     default: false
      t.string   :locale,                     default: :en
      t.string   :provider
      t.string   :uid
      t.boolean  :receive_communications_two, default: false
      t.boolean  :banned
      t.timestamps
    end  unless table_exists?(:customers)
    add_index(:customers, [:remember_token], name: :index_customers_on_remember_token, unique: true, using: :btree) unless index_exists?(:customers, :remember_token)
    add_index(:customers, [:reset_password_token], name: :index_customers_on_reset_password_token, unique: true, using: :btree) unless index_exists?(:customers, :reset_password_token)

    create_table :device_transactions do |t|
      t.references :event, index: true, foreign_key: true
      t.string   :action
      t.string   :device_uid
      t.integer  :device_db_index
      t.string   :device_created_at
      t.string   :device_created_at_fixed
      t.string   :initialization_type
      t.integer  :number_of_transactions
      t.integer  :status_code,             default: 0
      t.string   :status_message
      t.timestamps
    end  unless table_exists?(:device_transactions)

    create_table :devices do |t|
      t.string   :device_model
      t.string   :imei
      t.string   :mac
      t.string   :serial_number
      t.string   :asset_tracker
      t.timestamps
    end  unless table_exists?(:devices)
    add_index(:devices, [:mac, :imei, :serial_number], name: :index_devices_on_mac_and_imei_and_serial_number, unique: true, using: :btree) unless index_exists?(:devices, [:mac, :imei, :serial_number])

    create_table :entitlements do |t|
      t.references :access, index: true
      t.references :event, index: true, foreign_key: true
      t.integer  :memory_position,                     null: false
      t.integer  :memory_length,   default: 1
      t.string   :mode,            default: :counter
      t.timestamps
    end  unless table_exists?(:entitlements)

    create_table :event_translations do |t|
      t.references :event, index: true, foreign_key: true
      t.string   :locale,                             null: false
      t.string   :gtag_name
      t.text     :info
      t.text     :disclaimer
      t.text     :refund_success_message
      t.text     :mass_email_claim_notification
      t.text     :gtag_assignation_notification
      t.text     :gtag_form_disclaimer
      t.text     :agreed_event_condition_message
      t.text     :refund_disclaimer
      t.text     :bank_account_disclaimer
      t.text     :receive_communications_message
      t.text     :privacy_policy
      t.text     :terms_of_use
      t.text     :receive_communications_two_message
      t.timestamps
    end  unless table_exists?(:event_translations)
    add_index(:event_translations, [:locale], name: :index_event_translations_on_locale, using: :btree) unless index_exists?(:event_translations, :locale)

    create_table :friendly_id_slugs do |t|
      t.string   :slug,                      null: false
      t.integer  :sluggable_id,              null: false
      t.string   :sluggable_type, limit: 50
      t.string   :scope
    end  unless table_exists?(:friendly_id_slugs)
    add_index(:friendly_id_slugs, [:slug, :sluggable_type, :scope], name: :index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope, unique: true, using: :btree) unless index_exists?(:friendly_id_slugs, [:slug, :sluggable_type, :scope])
    add_index(:friendly_id_slugs, [:slug, :sluggable_type], name: :index_friendly_id_slugs_on_slug_and_sluggable_type, using: :btree) unless index_exists?(:friendly_id_slugs, [:slug, :sluggable_type])
    add_index(:friendly_id_slugs, [:sluggable_id], name: :index_friendly_id_slugs_on_sluggable_id, using: :btree) unless index_exists?(:friendly_id_slugs, :sluggable_id)
    add_index(:friendly_id_slugs, [:sluggable_type], name: :index_friendly_id_slugs_on_sluggable_type, using: :btree) unless index_exists?(:friendly_id_slugs, :sluggable_type)

    create_table :gtags do |t|
      t.references :event, index: true, foreign_key: true
      t.string   :tag_uid,                                                                null: false
      t.boolean  :banned,                                           default: false
      t.string   :format,                                           default: :wristband
      t.integer  :activation_counter,                               default: 1
      t.boolean  :loyalty,                                          default: false
      t.boolean  :active,                                           default: true
      t.decimal  :credits,                  precision: 8, scale: 2
      t.decimal  :refundable_credits,       precision: 8, scale: 2
      t.decimal  :final_balance,            precision: 8, scale: 2
      t.decimal  :final_refundable_balance, precision: 8, scale: 2
      t.references :customer, index: true, foreign_key: true
      t.timestamps
    end  unless table_exists?(:gtags)

    create_table :orders do |t|
      t.string   :status,       default: :in_progress, null: false
      t.datetime :completed_at
      t.json     :payment_data
      t.string   :gateway
      t.references :customer, index: true, foreign_key: true
      t.timestamps
    end  unless table_exists?(:orders)

    create_table :order_items do |t|
      t.references :order, index: true, foreign_key: true
      t.references :catalog_item, index: true, foreign_key: true
      t.decimal  :amount,          precision: 8, scale: 2
      t.decimal  :total,           precision: 8, scale: 2, null: false
      t.boolean  :redeemed
      t.integer  :counter
      t.timestamps
    end  unless table_exists?(:order_items)

    create_table :pack_catalog_items do |t|
      t.references :pack, index: true
      t.references :catalog_item, index: true, foreign_key: true
      t.decimal  :amount,          precision: 8, scale: 2
      t.timestamps
    end  unless table_exists?(:pack_catalog_items)

    create_table :payment_gateways do |t|
      t.references :event, index: true, foreign_key: true
      t.string   :gateway
      t.json     :data
      t.boolean  :refund
      t.boolean  :topup
      t.timestamps
    end  unless table_exists?(:payment_gateways)

    create_table :products do |t|
      t.references :event, index: true, foreign_key: true
      t.string   :name
      t.boolean  :is_alcohol,   default: false
      t.string   :description
      t.float    :vat,          default: 0.0
      t.string   :product_type
      t.timestamps
    end  unless table_exists?(:products)

    create_table :refunds do |t|
      t.decimal  :amount,      precision: 8, scale: 2, null: false
      t.string   :status
      t.decimal  :fee,         precision: 8, scale: 2
      t.string   :iban
      t.string   :swift
      t.decimal  :money,       precision: 8, scale: 2
      t.references :customer, index: true, foreign_key: true
      t.timestamps
    end  unless table_exists?(:refunds)

    create_table :station_catalog_items do |t|
      t.references :catalog_item, index: true, foreign_key: true
      t.float    :price,                           null: false
      t.boolean  :hidden,          default: false
      t.references :station, index: true, foreign_key: true
      t.timestamps
    end  unless table_exists?(:station_catalog_items)

    create_table :station_parameters do |t|
      t.references :station, index: true, foreign_key: true
      t.integer  :station_parametable_id,   null: false
      t.string   :station_parametable_type, null: false
      t.timestamps
    end  unless table_exists?(:station_parameters)

    create_table :station_products do |t|
      t.references :product, index: true, foreign_key: true
      t.float    :price,                      null: false
      t.integer  :position
      t.boolean  :hidden,     default: false
      t.references :station, index: true, foreign_key: true
      t.timestamps
    end  unless table_exists?(:station_products)

    create_table :ticket_types do |t|
      t.references :event, index: true, foreign_key: true
      t.references :company_event_agreement, index: true, foreign_key: true
      t.string   :name
      t.string   :company_code
      t.boolean  :hidden,                     default: false
      t.references :catalog_item, index: true, foreign_key: true
      t.timestamps
    end  unless table_exists?(:ticket_types)

    create_table :tickets do |t|
      t.references :event, index: true, foreign_key: true
      t.references :ticket_type, index: true, foreign_key: true
      t.string   :code
      t.boolean  :redeemed,             default: false, null: false
      t.boolean  :banned,               default: false
      t.string   :purchaser_first_name
      t.string   :purchaser_last_name
      t.string   :purchaser_email
      t.references :customer, index: true, foreign_key: true
      t.string   :description
      t.timestamps
    end  unless table_exists?(:tickets)

    create_table :topup_credits do |t|
      t.float    :amount
      t.references :credit, index: true
      t.boolean  :hidden,     default: false
      t.references :station, index: true, foreign_key: true
      t.timestamps
    end  unless table_exists?(:topup_credits)

    create_table :transactions do |t|
      t.references :event, index: true, foreign_key: true
      t.string   :type
      t.string   :transaction_origin
      t.string   :action
      t.string   :customer_tag_uid
      t.string   :operator_tag_uid
      t.references :station, index: true, foreign_key: true
      t.string   :device_uid
      t.integer  :device_db_index
      t.string   :device_created_at
      t.string   :device_created_at_fixed
      t.integer  :gtag_counter
      t.integer  :counter
      t.integer  :activation_counter
      t.string   :status_message
      t.integer  :status_code
      t.integer  :order_item_counter
      t.references :access, index: true
      t.integer  :direction
      t.string   :final_access_value
      t.string   :message
      t.string   :ticket_code
      t.float    :credits
      t.float    :refundable_credits
      t.float    :final_balance
      t.float    :final_refundable_balance
      t.references :catalog_item, index: true, foreign_key: true
      t.float    :items_amount
      t.float    :price
      t.string   :payment_method
      t.string   :payment_gateway
      t.references :ticket, index: true, foreign_key: true
      t.integer  :operator_activation_counter
      t.integer  :priority
      t.string   :operator_value
      t.references :operator_station, index: true
      t.references :order, index: true, foreign_key: true
      t.references :gtag, index: true, foreign_key: true
      t.references :customer, index: true, foreign_key: true
      t.timestamps
    end  unless table_exists?(:transactions)
    add_index(:transactions, [:type], name: :index_transactions_on_type, using: :btree) unless index_exists?(:transactions, :type)

    unless table_exists?(:sale_items)
      create_table :sale_items do |t|
        t.references :product, index: true, foreign_key: true
        t.integer :quantity
        t.float   :unit_price
        t.references :credit_transaction, index: true
        t.timestamps
      end
      add_foreign_key "sale_items", "transactions", column: "credit_transaction_id"
    end
  end
end