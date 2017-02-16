# == Schema Information
#
# Table name: events
#
#  address_mandatory               :boolean
#  agreed_event_condition          :boolean
#  background_content_type         :string
#  background_file_name            :string
#  background_file_size            :integer
#  birthdate_mandatory             :boolean
#  currency                        :string           default("USD"), not null
#  days_to_keep_backup             :integer          default(5)
#  device_basic_db_content_type    :string
#  device_basic_db_file_name       :string
#  device_basic_db_file_size       :integer
#  device_full_db_content_type     :string
#  device_full_db_file_name        :string
#  device_full_db_file_size        :integer
#  end_date                        :datetime
#  eventbrite_client_key           :string
#  eventbrite_client_secret        :string
#  eventbrite_event                :string
#  eventbrite_token                :string
#  fast_removal_password           :string           default("123456")
#  gender_mandatory                :boolean
#  gtag_deposit_fee                :integer          default(0)
#  gtag_type                       :string           default("ultralight_c")
#  iban_enabled                    :boolean          default(TRUE)
#  initial_topup_fee               :integer          default(0)
#  logo_content_type               :string
#  logo_file_name                  :string
#  logo_file_size                  :integer
#  maximum_gtag_balance            :integer          default(300)
#  mifare_classic_private_key_a    :string
#  mifare_classic_private_key_b    :string
#  mifare_classic_public_key       :string
#  name                            :string           not null
#  official_address                :string
#  official_name                   :string
#  phone_mandatory                 :boolean
#  pos_update_online_orders        :boolean          default(FALSE)
#  private_zone_password           :string           default("123456")
#  receive_communications          :boolean
#  receive_communications_two      :boolean
#  registration_num                :string
#  slug                            :string           not null
#  start_date                      :datetime
#  state                           :integer          default("created")
#  style                           :text
#  support_email                   :string           default("support@glownet.com"), not null
#  sync_time_basic_download        :integer          default(5)
#  sync_time_customers             :integer          default(10)
#  sync_time_event_parameters      :integer          default(1)
#  sync_time_gtags                 :integer          default(10)
#  sync_time_server_date           :integer          default(1)
#  sync_time_tickets               :integer          default(5)
#  timezone                        :string           default("UTC")
#  token                           :string
#  topup_fee                       :integer          default(0)
#  topup_initialize_gtag           :boolean          default(TRUE)
#  touchpoint_update_online_orders :boolean          default(FALSE)
#  transaction_buffer              :integer          default(100)
#  ultralight_c_private_key        :string
#  ultralight_ev1_private_key      :string
#
# Indexes
#
#  index_events_on_slug  (slug) UNIQUE
#

FactoryGirl.define do
  factory :event do
    name { "Event #{SecureRandom.hex(16)}" }
    state "started"
    start_date { Time.zone.now }
    end_date { Time.zone.now + 2.days }
    support_email "support@glownet.com"
    currency "EUR"
    gtag_type "ultralight_c"

    # Event states

    trait :launched do
      state "launched"
    end

    trait :started do
      state "started"
    end

    trait :finished do
      state "finished"
    end

    trait :closed do
      state "closed"
    end

    after :create do |event|
      event.create_credit(value: 1, step: 5, min_purchasable: 0, max_purchasable: 300, initial_amount: 0, name: "CR")
    end
  end
end
