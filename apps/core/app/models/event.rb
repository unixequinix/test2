# == Schema Information
#
# Table name: events
#
#  id                      :integer          not null, primary key
#  name                    :string           not null
#  aasm_state              :string
#  slug                    :string           not null
#  location                :string
#  support_email           :string           default("support@glownet.com"), not null
#  logo_file_name          :string
#  logo_content_type       :string
#  background_file_name    :string
#  background_content_type :string
#  url                     :string
#  background_type         :string           default("fixed")
#  currency                :string           default("USD"), not null
#  host_country            :string           default("US"), not null
#  token                   :string
#  description             :text
#  style                   :text
#  logo_file_size          :integer
#  background_file_size    :integer
#  features                :integer          default(0), not null
#  registration_parameters :integer          default(0), not null
#  locales                 :integer          default(1), not null
#  payment_services        :integer          default(0), not null
#  refund_services         :integer          default(0), not null
#  gtag_assignation        :boolean          default(TRUE), not null
#  ticket_assignation      :boolean          default(TRUE), not null
#  logo_updated_at         :datetime
#  background_updated_at   :datetime
#  start_date              :datetime
#  end_date                :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  token_symbol            :string           default("t")
#  company_name            :string
#

class Event < ActiveRecord::Base
  nilify_blanks
  translates :info, :disclaimer, :refund_success_message, :mass_email_claim_notification,
             :refund_disclaimer, :bank_account_disclaimer, :gtag_assignation_notification,
             :gtag_form_disclaimer, :gtag_name, :agreed_event_condition_message,
             fallbacks_for_empty_translations: true

  # State machine
  include EventState
  # FlagShihTzu
  include EventFlags

  # Associations
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

  extend FriendlyId
  friendly_id :name, use: :slugged

  S3_FOLDER = Rails.application.secrets.s3_images_folder

  has_attached_file(
    :logo,
    path: "#{S3_FOLDER}/event/:id/logos/:style/:filename",
    url: "#{S3_FOLDER}/event/:id/logos/:style/:basename.:extension",
    styles: { email: "x120", paypal: "x50" },
    default_url: ":default_event_image_url")

  has_attached_file(
    :background,
    path: "#{S3_FOLDER}/event/:id/backgrounds/:filename",
    url: "#{S3_FOLDER}/event/:id/backgrounds/:basename.:extension",
    default_url: ":default_event_background_url")

  # Hooks
  before_create :generate_token

  # Validations
  validates :name, :support_email, presence: true
  validates :name, uniqueness: true
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}

  def standard_credit_price
    credits.standard.value
  end

  def total_credits
    CustomerCredit.where(profile: profiles).map(&:amount).sum
  end

  def total_refundable_money(_refund_service)
    creds = CustomerCredit.where(profile: profiles)
    creds.map(&:refundable_amount).sum * standard_credit_price
  end

  def total_refundable_gtags(refund_service)
    # .count returns a hash created by the group method.
    gtag_query(refund_service).count.length
  end

  def get_parameter(category, group, name)
    event_parameters.includes(:parameter)
                    .find_by(parameters: { category: category, group: group, name: name })
                    &.value
  end

  def selected_locales_formated
    selected_locales.map { |key| key.to_s.gsub("_lang", "") }
  end

  def refund_fee(refund_service)
    get_parameter("refund", refund_service, "fee")
  end

  def refund_minimun(refund_service)
    get_parameter("refund", refund_service, "minimum")
  end

  def only_credits_purchasable?
    purchasable_items = stations.find_by_name("Customer Portal").station_catalog_items
    purchasable_items.count > 0 &&
      purchasable_items.joins(:catalog_item).where.not(
        catalog_items: { catalogable_type: "Credit" }).count == 0
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

  def gtag_query(refund_service)
    fee = refund_fee(refund_service)
    min = refund_minimun(refund_service)
    gtags.joins(credential_assignments: [profile: :customer_credits])
         .where("credential_assignments.aasm_state = 'assigned'")
         .having("sum(customer_credits.credit_value * customer_credits.final_refundable_balance)" \
              " - #{fee} >= #{min}")
         .having("sum(customer_credits.credit_value * customer_credits.final_refundable_balance)" \
              " - #{fee} > 0")
         .group("gtags.id")
  end

  def generate_token
    loop do
      self.token = SecureRandom.hex(6).upcase
      break unless self.class.exists?(token: token)
    end
  end
end
