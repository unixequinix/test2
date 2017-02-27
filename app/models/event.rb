class Event < ActiveRecord::Base
  has_many :transactions, dependent: :restrict_with_error
  has_many :tickets, dependent: :destroy
  has_many :catalog_items, dependent: :destroy
  has_many :ticket_types, dependent: :destroy
  has_many :companies, dependent: :destroy
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

  accepts_nested_attributes_for :credit

  belongs_to :owner, class_name: 'User'

  scope :with_state, ->(state) { where state: state }

  extend FriendlyId
  friendly_id :name, use: :slugged

  S3_FOLDER = "#{Rails.application.secrets.s3_images_folder}/event/:id/".freeze
  LOCALES = [:en, :es, :it, :de, :th].freeze

  enum state: { created: 1, launched: 2, started: 3, finished: 4, closed: 5 }
  enum gtag_format: { both: 0, wristband: 1, card: 2 }

  has_attached_file(:logo, path: "#{S3_FOLDER}logos/:style/:filename", url: "#{S3_FOLDER}logos/:style/:basename.:extension", styles: { email: "x120", paypal: "x50" }) # rubocop:disable Metrics/LineLength
  has_attached_file(:background, path: "#{S3_FOLDER}backgrounds/:filename", url: "#{S3_FOLDER}backgrounds/:basename.:extension", default_url: "/assets/background-default.jpg") # rubocop:disable Metrics/LineLength
  has_attached_file(:device_full_db, path: "#{S3_FOLDER}device_full_db/full_db.:extension", url: "#{S3_FOLDER}device_full_db/full_db.:extension", use_timestamp: false) # rubocop:disable Metrics/LineLength
  has_attached_file(:device_basic_db, path: "#{S3_FOLDER}device_basic_db/basic_db.:extension", url: "#{S3_FOLDER}device_basic_db/basic_db.:extension", use_timestamp: false) # rubocop:disable Metrics/LineLength

  before_create :generate_tokens

  validates :name, :support_email, :timezone, presence: true
  validates :sync_time_gtags, :sync_time_tickets, :transaction_buffer, :days_to_keep_backup, :sync_time_customers, :sync_time_server_date, :sync_time_basic_download, :sync_time_event_parameters, numericality: { greater_than: 0 } # rubocop:disable Metrics/LineLength
  validates :gtag_deposit_fee, :initial_topup_fee, :topup_fee, numericality: { greater_than_or_equal_to: 0 }
  validates :maximum_gtag_balance, :credit_step, numericality: { greater_than: 0 }
  validates :name, uniqueness: true
  validates :support_email, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validate :end_date_after_start_date
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}

  do_not_validate_attachment_file_type :device_full_db
  do_not_validate_attachment_file_type :device_basic_db

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
    state.in? %w(launched started finished)
  end

  def initial_setup!
    create_credit!(value: 1, name: "#{name} CRD")
    companies.create!(name: "Glownet", hidden: true)
    user_flags.create!(name: "alcohol_forbidden")
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
