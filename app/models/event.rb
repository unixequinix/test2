# == Schema Information
#
# Table name: events
#
#  aasm_state                   :string
#  background_content_type      :string
#  background_file_name         :string
#  background_file_size         :integer
#  background_type              :string           default("fixed")
#  company_name                 :string
#  currency                     :string           default("USD"), not null
#  device_basic_db_content_type :string
#  device_basic_db_file_name    :string
#  device_basic_db_file_size    :integer
#  device_full_db_content_type  :string
#  device_full_db_file_name     :string
#  device_full_db_file_size     :integer
#  device_settings              :jsonb            not null
#  end_date                     :datetime
#  eventbrite_client_key        :string
#  eventbrite_client_secret     :string
#  eventbrite_event             :string
#  eventbrite_token             :string
#  gtag_assignation             :boolean          default(FALSE)
#  gtag_settings                :jsonb            not null
#  host_country                 :string           default("US"), not null
#  location                     :string
#  logo_content_type            :string
#  logo_file_name               :string
#  logo_file_size               :integer
#  name                         :string           not null
#  official_address             :string
#  official_name                :string
#  registration_num             :string
#  registration_settings        :jsonb            not null
#  slug                         :string           not null
#  start_date                   :datetime
#  style                        :text
#  support_email                :string           default("support@glownet.com"), not null
#  ticket_assignation           :boolean          default(FALSE)
#  timezone                     :string           default("UTC")
#  token                        :string
#  token_symbol                 :string           default("t")
#  url                          :string
#
# Indexes
#
#  index_events_on_slug  (slug) UNIQUE
#

class Event < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
  translates :info, :disclaimer, :terms_of_use, :privacy_policy, :refund_success_message,
             :refund_disclaimer, :bank_account_disclaimer,
             :gtag_assignation_notification, :gtag_form_disclaimer, :gtag_name,
             :agreed_event_condition_message, :receive_communications_message, :receive_communications_two_message,
             fallbacks_for_empty_translations: true

  has_many :catalog_items, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :ticket_types, dependent: :destroy
  has_many :companies, through: :company_event_agreements
  has_many :company_event_agreements, dependent: :destroy
  has_many :entitlements, dependent: :destroy
  has_many :gtags, dependent: :destroy
  has_many :payment_gateways, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :stations, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_many :device_transactions, dependent: :destroy
  has_many :user_flags, dependent: :destroy
  has_many :accesses, dependent: :destroy
  has_many :packs, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_one :credit, dependent: :destroy

  scope :status, -> (status) { where aasm_state: status }

  extend FriendlyId
  friendly_id :name, use: :slugged

  S3_FOLDER = Rails.application.secrets.s3_images_folder
  REGISTRATION_SETTINGS = [:phone, :address, :city, :country, :postcode, :gender, :birthdate, :agreed_event_condition, :receive_communications, :receive_communications_two].freeze # rubocop:disable Metrics/LineLength
  LOCALES = [:en, :es, :it, :de, :th].freeze
  BACKGROUND_FIXED = "fixed".freeze
  BACKGROUND_REPEAT = "repeat".freeze
  BACKGROUND_TYPES = [BACKGROUND_FIXED, BACKGROUND_REPEAT].freeze

  include AASM

  aasm do
    state :created, initial: true
    state :launched
    state :started
    state :finished
    state :closed

    event :launch do
      transitions from: :created, to: :launched
    end

    event :start do
      transitions from: :launched, to: :started
      # TODO: Validates Company Ticket Types
      # TODO: Validates Device Private Key
    end

    event :finish do
      transitions from: :started, to: :finished
    end

    event :close do
      transitions from: :finished, to: :closed
    end

    event :reboot do
      transitions from: :closed, to: :created
    end
  end

  has_attached_file(
    :logo,
    path: "#{S3_FOLDER}/event/:id/logos/:style/:filename",
    url: "#{S3_FOLDER}/event/:id/logos/:style/:basename.:extension",
    styles: { email: "x120", paypal: "x50" },
    default_url: ":default_event_image_url"
  )

  has_attached_file(
    :background,
    path: "#{S3_FOLDER}/event/:id/backgrounds/:filename",
    url: "#{S3_FOLDER}/event/:id/backgrounds/:basename.:extension",
    default_url: ":default_event_background_url"
  )

  has_attached_file(
    :device_full_db,
    path: "#{S3_FOLDER}/event/:id/device_full_db/full_db.:extension",
    url: "#{S3_FOLDER}/event/:id/device_full_db/full_db.:extension",
    use_timestamp: false
  )

  has_attached_file(
    :device_basic_db,
    path: "#{S3_FOLDER}/event/:id/device_basic_db/basic_db.:extension",
    url: "#{S3_FOLDER}/event/:id/device_basic_db/basic_db.:extension",
    use_timestamp: false
  )

  before_create :generate_token

  validates :name, :support_email, :timezone, presence: true
  validates :name, uniqueness: true
  validates :agreed_event_condition_message, presence: true, if: :agreed_event_condition?
  validates :receive_communications_message, presence: true, if: :receive_communications?
  validates :receive_communications_two_message, presence: true, if: :receive_communications_two?
  validate :end_date_after_start_date
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}

  do_not_validate_attachment_file_type :device_full_db
  do_not_validate_attachment_file_type :device_basic_db

  serialize :registration_settings, HashSerializer
  serialize :gtag_settings, HashSerializer
  serialize :device_settings, HashSerializer

  store_accessor :registration_settings, :phone, :address, :city, :country, :postcode, :gender, :birthdate, :agreed_event_condition, :receive_communications, :receive_communications_two # rubocop:disable Metrics/LineLength
  store_accessor :gtag_settings, :format, :gtag_type, :gtag_deposit, :ultralight_c, :mifare_classic, :ultralight_ev1, :cards_can_refund, :maximum_gtag_balance, :wristbands_can_refund # rubocop:disable Metrics/LineLength
  store_accessor :device_settings, :min_version_apk, :private_zone_password, :fast_removal_password, :uid_reverse, :touchpoint_update_online_orders, :pos_update_online_orders, :topup_initialize_gtag, :cypher_enabled, :gtag_blacklist, :transaction_buffer, :days_to_keep_backup, :days_to_keep_backup_min, :sync_time_event_parameters, :sync_time_event_parameters_min, :sync_time_server_date, :sync_time_server_date_min, :sync_time_basic_download, :sync_time_basic_download_min, :sync_time_tickets, :sync_time_tickets_min, :sync_time_gtags, :sync_time_gtags_min, :sync_time_customers, :sync_time_customers_min # rubocop:disable Metrics/LineLength

  def background_fixed?
    object.background_type.eql? BACKGROUND_FIXED
  end

  def background_repeat?
    object.background_type.eql? BACKGROUND_REPEAT
  end

  def self.background_types_selector
    BACKGROUND_TYPES.map { |f| [I18n.t("admin.event.background_types." + f.to_s), f] }
  end

  def topups?
    payment_gateways.map(&:topup).any?
  end

  def refunds?
    payment_gateways.map(&:refund).any?
  end

  def refunds
    Refund.includes(:customer).where(customers: { event_id: id })
  end

  def orders
    Order.joins(:customer).where(customers: { event_id: id })
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
    %w(launched started finished).include? aasm_state
  end

  # Defines a method with a question mark for each registration setting which returns true if the setting is present
  # Examples: @current_event.phone? / @current_event.address?
  REGISTRATION_SETTINGS.each do |method_name|
    define_method "#{method_name}?" do
      registration_settings && registration_settings[method_name.to_s] == "true"
    end
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank? || end_date >= start_date
    errors.add(:end_date, I18n.t("errors.messages.end_date_after_start_date"))
  end

  def generate_token
    loop do
      self.token = SecureRandom.hex(6).upcase
      break unless self.class.exists?(token: token)
    end
  end
end
