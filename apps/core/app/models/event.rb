# == Schema Information
#
# Table name: events
#
#  id                           :integer          not null, primary key
#  name                         :string           not null
#  aasm_state                   :string
#  slug                         :string           not null
#  location                     :string
#  support_email                :string           default("support@glownet.com"), not null
#  logo_file_name               :string
#  logo_content_type            :string
#  background_file_name         :string
#  background_content_type      :string
#  url                          :string
#  background_type              :string           default("fixed")
#  currency                     :string           default("USD"), not null
#  host_country                 :string           default("US"), not null
#  token                        :string
#  description                  :text
#  style                        :text
#  logo_file_size               :integer
#  background_file_size         :integer
#  features                     :integer          default(32), not null
#  registration_parameters      :integer          default(0), not null
#  locales                      :integer          default(1), not null
#  payment_services             :integer          default(0), not null
#  refund_services              :integer          default(0), not null
#  logo_updated_at              :datetime
#  background_updated_at        :datetime
#  start_date                   :datetime
#  end_date                     :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  token_symbol                 :string           default("t")
#  company_name                 :string
#  device_full_db_file_name     :string
#  device_full_db_content_type  :string
#  device_full_db_file_size     :integer
#  device_full_db_updated_at    :datetime
#  device_basic_db_file_name    :string
#  device_basic_db_content_type :string
#  device_basic_db_file_size    :integer
#  device_basic_db_updated_at   :datetime
#  official_address             :string
#  registration_num             :string
#  official_name                :string
#

class Event < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
  nilify_blanks
  translates :info, :disclaimer, :terms_of_use, :privacy_policy, :refund_success_message,
             :mass_email_claim_notification, :refund_disclaimer, :bank_account_disclaimer,
             :gtag_assignation_notification, :gtag_form_disclaimer, :gtag_name,
             :agreed_event_condition_message, :receive_communications_message,
             fallbacks_for_empty_translations: true

  include EventState # State machine
  include EventFlags # FlagShihTzu

  # Associations
  has_many :device_transactions
  has_many :company_ticket_types
  has_many :profiles
  has_many :event_parameters
  has_many :parameters, through: :event_parameters
  has_many :customers
  has_many :company_event_agreements
  has_many :companies, through: :company_event_agreements
  has_many :transactions
  has_many :products
  has_many :stations
  has_many :catalog_items
  has_many :credits, through: :catalog_items, source: :catalogable, source_type: "Credit" do
    def standard
      find_by(standard: true)
    end
  end
  has_many :tickets
  has_many :tickets_assignments, through: :tickets, source: :credential_assignments,
                                 class_name: "CredentialAssignment"
  has_many :gtags
  has_many :gtags_assignments, through: :gtags, source: :credential_assignments,
                               class_name: "CredentialAssignment"

  # Scopes
  scope :status, -> (status) { where aasm_state: status }

  extend FriendlyId
  friendly_id :name, use: :slugged

  S3_FOLDER = Rails.application.secrets.s3_images_folder

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
  validate :end_date_after_start_date
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}
  do_not_validate_attachment_file_type :device_full_db
  do_not_validate_attachment_file_type :device_basic_db

  def standard_credit_price
    credits.standard.value
  end

  def portal_station
    stations.find_by(category: "customer_portal")
  end

  def total_refundable_money
    profiles.sum(:refundable_credits) * standard_credit_price
  end

  def refund_fee(refund_service)
    get_parameter("refund", refund_service, "fee")
  end

  def refund_minimun(refund_service)
    get_parameter("refund", refund_service, "fee")
  end

  def get_parameter(category, group, name)
    event_parameters.includes(:parameter)
                    .find_by(parameters: { category: category, group: group, name: name })
                    &.value
  end

  def selected_locales_formated
    selected_locales.map { |key| key.to_s.gsub("_lang", "") }
  end

  def only_credits_purchasable?
    purchasable_items = stations.find_by_name("Customer Portal").station_catalog_items
    purchasable_items.count > 0 &&
      purchasable_items.joins(:catalog_item).where.not(
        catalog_items: { catalogable_type: "Credit" }
      ).count == 0
  end

  def autotopup_payment_services
    selected_autotopup_payment_services.select do |payment_service|
      get_parameter("payment", payment_service_parsed(payment_service), "autotopup") == "true"
    end
  end

  def selected_autotopup_payment_services
    selected_payment_services & EventDecorator::AUTOTOPUP_PAYMENT_SERVICES
  end

  def payment_service_parsed(payment_service)
    EventDecorator::PAYMENT_PLATFORMS[payment_service]
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
