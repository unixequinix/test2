# == Schema Information
#
# Table name: events
#
#  aasm_state                   :string
#  background_content_type      :string
#  background_file_name         :string
#  background_file_size         :integer
#  background_type              :string           default("fixed")
#  background_updated_at        :datetime
#  company_name                 :string
#  created_at                   :datetime         not null
#  currency                     :string           default("USD"), not null
#  device_basic_db_content_type :string
#  device_basic_db_file_name    :string
#  device_basic_db_file_size    :integer
#  device_basic_db_updated_at   :datetime
#  device_full_db_content_type  :string
#  device_full_db_file_name     :string
#  device_full_db_file_size     :integer
#  device_full_db_updated_at    :datetime
#  device_settings              :json
#  end_date                     :datetime
#  eventbrite_client_key        :string
#  eventbrite_client_secret     :string
#  eventbrite_event             :string
#  eventbrite_token             :string
#  gtag_assignation             :boolean          default(FALSE)
#  gtag_settings                :json
#  host_country                 :string           default("US"), not null
#  location                     :string
#  logo_content_type            :string
#  logo_file_name               :string
#  logo_file_size               :integer
#  logo_updated_at              :datetime
#  name                         :string           not null
#  official_address             :string
#  official_name                :string
#  registration_num             :string
#  registration_settings        :json
#  slug                         :string           not null
#  start_date                   :datetime
#  style                        :text
#  support_email                :string           default("support@glownet.com"), not null
#  ticket_assignation           :boolean          default(FALSE)
#  token                        :string
#  token_symbol                 :string           default("t")
#  updated_at                   :datetime         not null
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

  has_many :companies, through: :company_event_agreements
  has_many :company_event_agreements
  has_many :ticket_types
  has_many :customers
  has_many :entitlements
  has_many :gtags
  has_many :payment_gateways
  has_many :products
  has_many :stations
  has_many :tickets
  has_many :transactions
  has_many :device_transactions
  has_many :user_flags
  has_many :accesses
  has_many :catalog_items
  has_many :packs
  has_one :credit

  # Scopes
  scope :status, -> (status) { where aasm_state: status }

  extend FriendlyId
  friendly_id :name, use: :slugged

  S3_FOLDER = Rails.application.secrets.s3_images_folder
  REGISTRATION_SETTINGS = [:phone, :address, :city, :country, :postcode, :gender, :birthdate, :agreed_event_condition,
                           :receive_communications, :receive_communications_two].freeze
  LOCALES = [:en, :es, :it, :de, :th].freeze

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

  # Hooks
  before_create :generate_token

  # Validations
  validates :name, :support_email, presence: true
  validates :name, uniqueness: true
  validates :agreed_event_condition_message, presence: true, if: :agreed_event_condition?
  validates :receive_communications_message, presence: true, if: :receive_communications?
  validates :receive_communications_two_message, presence: true, if: :receive_communications_two?
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
  # Examples: current_event.phone? / current_event.address?
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
