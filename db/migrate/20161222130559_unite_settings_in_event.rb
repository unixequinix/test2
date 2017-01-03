class UniteSettingsInEvent < ActiveRecord::Migration
  def change
    add_column :events, :city_mandatory, :boolean
    add_column :events, :phone_mandatory, :boolean
    add_column :events, :gender_mandatory, :boolean
    add_column :events, :address_mandatory, :boolean
    add_column :events, :country_mandatory, :boolean
    add_column :events, :postcode_mandatory, :boolean
    add_column :events, :birthdate_mandatory, :boolean
    add_column :events, :agreed_event_condition, :boolean
    add_column :events, :receive_communications, :boolean
    add_column :events, :receive_communications_two, :boolean

    add_column :events, :gtag_format, :string, default: "standard"
    add_column :events, :gtag_type, :string, default: 'ultralight_c'
    add_column :events, :gtag_deposit, :integer, default: 0
    add_column :events, :maximum_gtag_balance, :integer, default: 300
    add_column :events, :cards_can_refund, :boolean, default: true
    add_column :events, :wristbands_can_refund, :boolean, default: true

    add_column :events, :min_apk_version, :string, default: "1.0"
    add_column :events, :uid_reverse, :boolean, default: false
    add_column :events, :topup_initialize_gtag, :boolean, default: true
    add_column :events, :pos_update_online_orders, :boolean, default: false
    add_column :events, :touchpoint_update_online_orders, :boolean, default: false
    add_column :events, :cypher_enabled, :boolean, default: false
    add_column :events, :fast_removal_password, :string, default: '123456'
    add_column :events, :private_zone_password, :string, default: '123456'

    add_column :events, :sync_time_gtags, :integer, default: 10
    add_column :events, :sync_time_tickets, :integer, default: 5
    add_column :events, :transaction_buffer, :integer, default: 100
    add_column :events, :days_to_keep_backup, :integer, default: 5
    add_column :events, :sync_time_customers, :integer, default: 10
    add_column :events, :sync_time_server_date, :integer, default: 1
    add_column :events, :sync_time_basic_download, :integer, default: 5
    add_column :events, :sync_time_event_parameters, :integer, default: 1

    add_column :events, :ultralight_c_private_key, :string
    add_column :events, :mifare_classic_public_key, :string
    add_column :events, :mifare_classic_private_key_a, :string
    add_column :events, :mifare_classic_private_key_b, :string
    add_column :events, :ultralight_ev1_private_key, :string

    Event.all.each do |event|
      event.city_mandatory = event.registration_settings["city"]
      event.phone_mandatory = event.registration_settings["phone"]
      event.gender_mandatory = event.registration_settings["gender"]
      event.address_mandatory = event.registration_settings["address"]
      event.country_mandatory = event.registration_settings["country"]
      event.postcode_mandatory = event.registration_settings["postcode"]
      event.birthdate_mandatory = event.registration_settings["birthdate"]
      event.agreed_event_condition = event.registration_settings["agreed_event_condition"]
      event.receive_communications = event.registration_settings["receive_communications"]
      event.receive_communications_two = event.registration_settings["receive_communications_two"]
      event.gtag_format = event.gtag_settings["gtag"]
      event.gtag_type = event.gtag_settings["gtag_type"]
      event.gtag_deposit = event.gtag_settings["gtag_deposit"]
      event.maximum_gtag_balance = event.gtag_settings["maximum_gtag_balance"]
      event.cards_can_refund = event.gtag_settings["cards_can_refund"]
      event.wristbands_can_refund = event.gtag_settings["wristbands_can_refund"]
      event.min_apk_version = event.device_settings["min_apk_version"]
      event.uid_reverse = event.device_settings["uid_reverse"]
      event.topup_initialize_gtag = event.device_settings["topup_initialize_gtag"]
      event.pos_update_online_orders = event.device_settings["pos_update_online_orders"]
      event.touchpoint_update_online_orders = event.device_settings["touchpoint_update_online_orders"]
      event.cypher_enabled = event.device_settings["cypher_enabled"]
      event.fast_removal_password = event.device_settings["fast_removal_password"]
      event.private_zone_password = event.device_settings["private_zone_password"]
      event.sync_time_gtags = event.device_settings["sync_time_gtags"]
      event.sync_time_tickets = event.device_settings["sync_time_tickets"]
      event.transaction_buffer = event.device_settings["transaction_buffer"]
      event.days_to_keep_backup = event.device_settings["days_to_keep_backup"]
      event.sync_time_customers = event.device_settings["sync_time_customers"]
      event.sync_time_server_date = event.device_settings["sync_time_server_date"]
      event.sync_time_basic_download = event.device_settings["sync_time_basic_download"]
      event.sync_time_event_parameters = event.device_settings["sync_time_event_parameters"]
      event.ultralight_c_private_key = event.gtag_settings["ultralight_c"]["ultralight_c_private_key"]
      event.mifare_classic_public_key = event.gtag_settings["mifare_classic"]["mifare_classic_public_key"]
      event.mifare_classic_private_key_a = event.gtag_settings["mifare_classic"]["mifare_classic_private_key_a"]
      event.mifare_classic_private_key_b = event.gtag_settings["mifare_classic"]["mifare_classic_private_key_b"]
      event.ultralight_ev1_private_key = event.gtag_settings["ultralight_ev1"]["ultralight_ev1_private_key"]
      event.save!
    end

    remove_column :events, :registration_settings, :jsonb
    remove_column :events, :gtag_settings, :jsonb
    remove_column :events, :device_settings, :jsonb
    remove_column :events, :min_apk_version, :string
    remove_column :events, :cypher_enabled, :boolean
    remove_column :events, :host_country, :string
    remove_column :events, :location, :string
    remove_column :events, :url, :string
  end
end






