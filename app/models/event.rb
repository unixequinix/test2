# == Schema Information
#
# Table name: events
#
#  address_mandatory               :boolean
#  agreed_event_condition          :boolean
#  background_content_type         :string
#  background_file_name            :string
#  background_file_size            :integer
#  background_type                 :string           default("fixed")
#  birthdate_mandatory             :boolean
#  cards_can_refund                :boolean          default(TRUE)
#  city_mandatory                  :boolean
#  company_name                    :string
#  country_mandatory               :boolean
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
#  gtag_assignation                :boolean          default(FALSE)
#  gtag_deposit_fee                :integer          default(0)
#  gtag_format                     :string           default("standard")
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
#  postcode_mandatory              :boolean
#  private_zone_password           :string           default("123456")
#  receive_communications          :boolean
#  receive_communications_two      :boolean
#  registration_num                :string
#  slug                            :string           not null
#  start_date                      :datetime
#  state                           :string           default("created")
#  style                           :text
#  support_email                   :string           default("support@glownet.com"), not null
#  sync_time_basic_download        :integer          default(5)
#  sync_time_customers             :integer          default(10)
#  sync_time_event_parameters      :integer          default(1)
#  sync_time_gtags                 :integer          default(10)
#  sync_time_server_date           :integer          default(1)
#  sync_time_tickets               :integer          default(5)
#  ticket_assignation              :boolean          default(FALSE)
#  timezone                        :string           default("UTC")
#  token                           :string
#  token_symbol                    :string           default("t")
#  topup_fee                       :integer          default(0)
#  topup_initialize_gtag           :boolean          default(TRUE)
#  touchpoint_update_online_orders :boolean          default(FALSE)
#  transaction_buffer              :integer          default(100)
#  ultralight_c_private_key        :string
#  ultralight_ev1_private_key      :string
#  wristbands_can_refund           :boolean          default(TRUE)
#
# Indexes
#
#  index_events_on_slug  (slug) UNIQUE
#

class Event < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
  translates :info, :disclaimer, :terms_of_use, :privacy_policy, :refund_success_message,
             :refund_disclaimer, :bank_account_disclaimer,
             :gtag_assignation_notification, :gtag_form_disclaimer,
             :agreed_event_condition_message, :receive_communications_message, :receive_communications_two_message,
             fallbacks_for_empty_translations: true

  has_many :transactions, dependent: :restrict_with_error
  has_many :tickets, dependent: :destroy
  has_many :catalog_items, dependent: :destroy
  has_many :ticket_types, dependent: :destroy
  has_many :companies, through: :company_event_agreements
  has_many :company_event_agreements, dependent: :destroy
  has_many :gtags, dependent: :destroy
  has_many :payment_gateways, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :stations, dependent: :destroy
  has_many :device_transactions, dependent: :destroy
  has_many :user_flags, dependent: :destroy
  has_many :accesses, dependent: :destroy
  has_many :packs, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :users, dependent: :destroy

  has_one :credit, dependent: :destroy

  belongs_to :owner, class_name: 'User'

  scope :with_state, ->(status) { where state: status }

  extend FriendlyId
  friendly_id :name, use: :slugged

  S3_FOLDER = "#{Rails.application.secrets.s3_images_folder}/event/:id/".freeze
  LOCALES = [:en, :es, :it, :de, :th].freeze
  BACKGROUND_FIXED = "fixed".freeze
  BACKGROUND_REPEAT = "repeat".freeze
  BACKGROUND_TYPES = [BACKGROUND_FIXED, BACKGROUND_REPEAT].freeze
  STATES = %w(created launched started finished closed).freeze

  has_attached_file(:logo, path: "#{S3_FOLDER}logos/:style/:filename", url: "#{S3_FOLDER}logos/:style/:basename.:extension", styles: { email: "x120", paypal: "x50" }, default_url: ":default_event_image_url") # rubocop:disable Metrics/LineLength
  has_attached_file(:background, path: "#{S3_FOLDER}backgrounds/:filename", url: "#{S3_FOLDER}backgrounds/:basename.:extension", default_url: ":default_event_background_url") # rubocop:disable Metrics/LineLength
  has_attached_file(:device_full_db, path: "#{S3_FOLDER}device_full_db/full_db.:extension", url: "#{S3_FOLDER}device_full_db/full_db.:extension", use_timestamp: false) # rubocop:disable Metrics/LineLength
  has_attached_file(:device_basic_db, path: "#{S3_FOLDER}device_basic_db/basic_db.:extension", url: "#{S3_FOLDER}device_basic_db/basic_db.:extension", use_timestamp: false) # rubocop:disable Metrics/LineLength

  before_create :generate_tokens

  validates :name, :support_email, :timezone, presence: true
  validates :sync_time_gtags, :sync_time_tickets, :transaction_buffer, :days_to_keep_backup, :sync_time_customers, :sync_time_server_date, :sync_time_basic_download, :sync_time_event_parameters, numericality: { greater_than: 0 } # rubocop:disable Metrics/LineLength
  # validates :gtag_deposit_fee, :topup_fee, :card_return_fee, numericality: { greater_than_or_equal_to: 0 }
  validates :name, uniqueness: true
  validates :agreed_event_condition_message, presence: true, if: :agreed_event_condition?
  validates :receive_communications_message, presence: true, if: :receive_communications?
  validates :receive_communications_two_message, presence: true, if: :receive_communications_two?
  validate :end_date_after_start_date
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}

  do_not_validate_attachment_file_type :device_full_db
  do_not_validate_attachment_file_type :device_basic_db

  STATES.each do |method_name|
    define_method "#{method_name}?" do
      state == method_name
    end
  end

  def background_fixed?
    object.background_type.eql? BACKGROUND_FIXED
  end

  def background_repeat?
    object.background_type.eql? BACKGROUND_REPEAT
  end

  def self.background_types_selector
    BACKGROUND_TYPES.map { |f| f }
  end

  def topups?
    payment_gateways.map(&:topup).any?
  end

  def refunds?
    payment_gateways.map(&:refund).any?
  end

  def eventbrite?
    eventbrite_token.present? && eventbrite_event.present?
  end

  def credit_price
    credit.value
  end

  def portal_station
    stations.find_by(category: "customer_portal")
  end

  def total_refundable_money
    customers.sum(:refundable_credits) * credit_price
  end

  def active?
    %w(launched started finished).include? state
  end

  def initial_setup!
    create_credit!(value: 1, name: "CRD", step: 5, min_purchasable: 0, max_purchasable: 300, initial_amount: 0)
    user_flags.create!(name: "alcohol_forbidden", step: 1)
    station = stations.create! name: "Customer Portal", category: "customer_portal", group: "access"
    station.station_catalog_items.create(catalog_item: credit, price: 1)
    stations.create! name: "CS Topup/Refund", category: "cs_topup_refund", group: "event_management"
    stations.create! name: "CS Accreditation", category: "cs_accreditation", group: "event_management"
    stations.create! name: "Glownet Food", category: "hospitality_top_up", group: "event_management"
    stations.create! name: "Touchpoint", category: "touchpoint", group: "touchpoint"
    stations.create! name: "Operator Permissions", category: "operator_permissions", group: "event_management"
    stations.create! name: "Gtag Recycler", category: "gtag_recycler", group: "glownet"
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank? || end_date >= start_date
    errors.add(:end_date, t("errors.messages.end_date_after_start_date"))
  end

  def generate_tokens
    self.token = SecureRandom.hex(6).upcase
    self.ultralight_c_private_key = SecureRandom.hex(16)
    self.ultralight_ev1_private_key = SecureRandom.hex(16)
    self.mifare_classic_public_key = SecureRandom.hex(6)
    self.mifare_classic_private_key_a = SecureRandom.hex(6)
    self.mifare_classic_private_key_b = SecureRandom.hex(6)
  end
end
