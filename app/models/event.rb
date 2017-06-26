class Event < ApplicationRecord # rubocop:disable Metrics/ClassLength
  has_many :device_registrations, dependent: :destroy
  has_many :devices, through: :device_registrations
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
  has_many :operator_permissions, dependent: :destroy
  has_many :packs, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :refunds, dependent: :destroy
  has_many :event_registrations, dependent: :destroy
  has_many :users, through: :event_registrations

  has_one :credit, dependent: :destroy

  belongs_to :event_serie, optional: true

  accepts_nested_attributes_for :credit

  scope(:with_state, ->(state) { where state: state })

  extend FriendlyId
  friendly_id :name, use: :slugged

  S3_FOLDER = "#{Rails.application.secrets.s3_images_folder}/event/:id/".freeze

  enum state: { created: 1, launched: 2, closed: 3 }
  enum bank_format: { nothing: 0, iban: 1, bsb: 2 }
  enum gtag_format: { both: 0, wristband: 1, card: 2 }

  has_attached_file(:logo, path: "#{S3_FOLDER}logos/:style/:filename", url: "#{S3_FOLDER}logos/:style/:basename.:extension", styles: { email: "x120", paypal: "x50", panel: "200x" }, default_url: ':default_event_image_url') # rubocop:disable Metrics/LineLength
  has_attached_file(:background, path: "#{S3_FOLDER}backgrounds/:filename", url: "#{S3_FOLDER}backgrounds/:basename.:extension", default_url: ':default_event_background_url') # rubocop:disable Metrics/LineLength
  has_attached_file(:device_full_db, path: "#{S3_FOLDER}device_full_db/full_db.:extension", url: "#{S3_FOLDER}device_full_db/full_db.:extension", use_timestamp: false) # rubocop:disable Metrics/LineLength
  has_attached_file(:device_basic_db, path: "#{S3_FOLDER}device_basic_db/basic_db.:extension", url: "#{S3_FOLDER}device_basic_db/basic_db.:extension", use_timestamp: false) # rubocop:disable Metrics/LineLength

  before_create :generate_tokens

  validates :name, :app_version, :support_email, :timezone, :start_date, :end_date, presence: true
  validates :sync_time_gtags, :sync_time_tickets, :transaction_buffer, :days_to_keep_backup, :sync_time_customers, :sync_time_server_date, :sync_time_basic_download, :sync_time_event_parameters, numericality: { greater_than: 0 } # rubocop:disable Metrics/LineLength
  validates :gtag_deposit_fee, :initial_topup_fee, :topup_fee, numericality: { greater_than_or_equal_to: 0 }
  validates :maximum_gtag_balance, :credit_step, numericality: { greater_than: 0 }
  validates :name, uniqueness: true
  validates :support_email, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :gtag_key, format: { with: /\A[a-zA-Z0-9]+\z/, message: I18n.t("alerts.only_letters_and_numbers") }, length: { is: 32 }, unless: -> { :new_record? } # rubocop:disable Metrics/LineLength
  validate :end_date_after_start_date
  validate :refunds_start_after_end_date
  validate :refunds_end_after_refunds_start
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}

  do_not_validate_attachment_file_type :device_full_db
  do_not_validate_attachment_file_type :device_basic_db

  def self.try_to_open_refunds
    Event.where(state: "launched").find_each do |event|
      date = event.refunds_start_date
      next unless date
      Time.use_zone(event.timezone) { event.update(open_refunds: true) if Time.current >= Time.zone.parse(date.to_formatted_s(:human)) }
    end
  end

  def self.try_to_end_refunds
    Event.where(state: "launched").find_each do |event|
      date = event.refunds_end_date
      next unless date
      Time.use_zone(event.timezone) { event.update(open_refunds: false) if Time.current >= Time.zone.parse(date.to_formatted_s(:human)) }
    end
  end

  def formatted_start_date
    start_date.to_formatted_s(:best_in_place)
  end

  def formatted_end_date
    end_date.to_formatted_s(:best_in_place)
  end

  def transactions_with_bad_time
    time_range = (start_date.to_formatted_s(:transactions)..end_date.to_formatted_s(:transactions))
    transactions.onsite.where(action: %w[sale sale_refund]).order(:device_db_index).where.not(device_created_at: time_range)
  end

  def registrations_with_bad_time
    bad_devices = devices.where(mac: transactions_with_bad_time.pluck(:device_uid).uniq)
    device_registrations.where(device: bad_devices)
  end

  def resolve_time!
    registrations_with_bad_time.map(&:resolve_time!)
  end

  def valid_app_version?(device_version)
    return true if app_version.eql?("all")
    return false unless device_version
    Gem::Version.new(app_version) <= Gem::Version.new(device_version.delete("^0-9\."))
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

  def initial_setup!
    create_credit!(value: 1, name: "CRD")
    companies.create!(name: "Glownet", hidden: true)
    user_flags.create!(name: "alcohol_forbidden")
    user_flags.create!(name: "banned")
    station = stations.create! name: "Customer Portal", category: "customer_portal"
    station.station_catalog_items.create(catalog_item: credit, price: 1)
    stations.create! name: "CS Topup/Refund", category: "cs_topup_refund"
    stations.create! name: "CS Accreditation", category: "cs_accreditation"
    stations.create! name: "Glownet Food", category: "hospitality_top_up"
    stations.create! name: "Touchpoint", category: "touchpoint"
    stations.create! name: "Operator Permissions", category: "operator_permissions"
    stations.create! name: "Gtag Recycler", category: "gtag_recycler"
    stations.create! name: "Gtag Replacement", category: "gtag_replacement"
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank? || end_date >= start_date
    errors.add(:end_date, "must be after start date")
  end

  def refunds_start_after_end_date
    return if end_date.blank? || refunds_start_date.blank? || refunds_start_date >= end_date
    errors.add(:refunds_start_date, "must be after end date")
  end

  def refunds_end_after_refunds_start
    return if refunds_end_date.blank? || refunds_start_date.blank? || refunds_end_date >= refunds_start_date
    errors.add(:refunds_end_date, "must be after refunds start date")
  end

  def generate_tokens
    self.token = SecureRandom.hex(6).upcase
    self.gtag_key = SecureRandom.hex(16).upcase
  end
end
