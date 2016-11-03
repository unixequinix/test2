class Event < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
  nilify_blanks
  translates :info, :disclaimer, :terms_of_use, :privacy_policy, :refund_success_message,
             :mass_email_claim_notification, :refund_disclaimer, :bank_account_disclaimer,
             :gtag_assignation_notification, :gtag_form_disclaimer, :gtag_name,
             :agreed_event_condition_message, :receive_communications_message, :receive_communications_two_message,
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
  has_many :accesses, through: :catalog_items, source: :catalogable, source_type: "Access"
  has_many :packs, through: :catalog_items, source: :catalogable, source_type: "Pack"
  has_many :credits, through: :catalog_items, source: :catalogable, source_type: "Credit" do
    def standard
      find_by(standard: true)
    end
  end
  has_many :tickets
  has_many :gtags

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
  validates :receive_communications_two_message, presence: true, if: :receive_communications_two?
  validate :end_date_after_start_date
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}
  do_not_validate_attachment_file_type :device_full_db
  do_not_validate_attachment_file_type :device_basic_db

  def claims
    Claim.joins(:profile).where(profiles: { event_id: id })
  end

  def refunds
    Refund.joins(claim: :profile).where(profiles: { event_id: id })
  end

  def customer_orders
    CustomerOrder.joins(:profile).where(profiles: { event_id: id })
  end

  def orders
    Order.joins(:profile).where(profiles: { event_id: id })
  end

  def payments
    Payment.joins(order: :profile).where(profiles: { event_id: id })
  end

  def credential_types
    CredentialType.joins(:catalog_item).where(catalog_items: { event_id: id }).includes(:catalog_item)
  end

  def eventbrite?
    eventbrite_token.present? && eventbrite_event.present?
  end

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
    get_parameter("refund", refund_service, "minimum")
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
    purchasable_items = stations.find_by_category("customer_portal").station_catalog_items
    purchasable_items.count > 0 &&
      purchasable_items.joins(:catalog_item)
                       .where.not(catalog_items: { catalogable_type: "Credit" }).count.zero?
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

  def active?
    %w(launched started finished).include? aasm_state
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
