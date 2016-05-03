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

  include FlagShihTzu

  has_flags 1 => :top_ups, 2 => :refunds, column: "features"
  has_flags 1 => :paypal, 2 => :redsys, 3 => :braintree, 4 => :stripe, 5 => :paypal_nvp,
            6 => :ideal, 7 => :sofort, 8 => :wirecard, column: "payment_services"
  has_flags 1 => :bank_account, 2 => :epg, 3 => :tipalti, 4 => :direct, column: "refund_services"
  has_flags 1 => :phone, 2 => :address, 3 => :city, 4 => :country, 5 => :postcode, 6 => :gender,
            7 => :birthdate, 8 => :agreed_event_condition, column: "registration_parameters"
  has_flags 1 => :en_lang, 2 => :es_lang, 3 => :it_lang, 4 => :th_lang, column: "locales"

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
    styles: { email: "x120" },
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

  # State machine
  include EventState

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
      .value
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

  private

  def gtag_query(refund_service)
    fee = refund_fee(refund_service)
    min = refund_minimun(refund_service)
    gtags.joins(credential_assignments: [profile: :customer_credits])
      .where("credential_assignments.aasm_state = 'assigned'")
      .having("sum(customer_credits.credit_value * customer_credits.final_refundable_balance) - " \
              "#{fee} >= #{min}")
      .having("sum(customer_credits.credit_value * customer_credits.final_refundable_balance) - " \
              "#{fee} > 0")
      .group("gtags.id")
  end

  def generate_token
    loop do
      self.token = SecureRandom.hex(6).upcase
      break unless self.class.exists?(token: token)
    end
  end
end
