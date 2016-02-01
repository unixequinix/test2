# == Schema Information
#
# Table name: events
#
#  id                      :integer          not null, primary key
#  name                    :string           not null
#  aasm_state              :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string           not null
#  location                :string
#  start_date              :datetime
#  end_date                :datetime
#  description             :text
#  support_email           :string           default("support@glownet.com"), not null
#  style                   :text
#  logo_file_name          :string
#  logo_content_type       :string
#  logo_file_size          :integer
#  logo_updated_at         :datetime
#  background_file_name    :string
#  background_content_type :string
#  background_file_size    :integer
#  background_updated_at   :datetime
#  url                     :string
#  background_type         :string           default("fixed")
#  features                :integer          default(0), not null
#  gtag_assignation        :boolean          default(TRUE), not null
#  payment_service         :string           default("redsys")
#  registration_parameters :integer          default(0), not null
#  currency                :string           default("USD"), not null
#  host_country            :string           default("US"), not null
#  locales                 :integer          default(1), not null
#  refund_services         :integer          default(0), not null
#  ticket_assignation      :boolean          default(TRUE), not null
#  token                   :string           not null
#

class Event < ActiveRecord::Base
  nilify_blanks
  translates :info, :disclaimer, :refund_success_message, :mass_email_claim_notification,
             :refund_disclaimer, :bank_account_disclaimer, :gtag_assignation_notification,
             :gtag_form_disclaimer, :gtag_name, :agreed_event_condition_message,
             fallbacks_for_empty_translations: true

  # Background Types
  BACKGROUND_FIXED = "fixed"
  BACKGROUND_REPEAT = "repeat"
  BACKGROUND_TYPES = [BACKGROUND_FIXED, BACKGROUND_REPEAT]

  # Payment Services
  REDSYS = "redsys"
  STRIPE = "stripe"
  PAYMENT_SERVICES = [REDSYS, STRIPE]

  # TODO: check if these constants should live here or in a view helper
  REFUND_SERVICES = [:bank_account, :epg, :tipalti]
  FEATURES = [:top_ups, :refunds]
  LOCALES = [:en_lang, :es_lang, :it_lang, :th_lang]
  REGISTRATION_PARAMETERS = [:phone, :address, :city, :country, :postcode, :gender, :birthdate, :agreed_event_condition]

  include FlagShihTzu

  has_flags 1 => :top_ups, 2 => :refunds, column: "features"
  has_flags 1 => :bank_account, 2 => :epg, 3 => :tipalti, column: "refund_services"
  has_flags 1 => :phone,
            2 => :address,
            3 => :city,
            4 => :country,
            5 => :postcode,
            6 => :gender,
            7 => :birthdate,
            8 => :agreed_event_condition,
            column: "registration_parameters"

  has_flags 1 => :en_lang, 2 => :es_lang, 3 => :it_lang, 4 => :th_lang, column: "locales"

  # Associations
  has_many :customer_event_profiles
  has_many :customers
  has_many :tickets
  has_many :gtags
  has_many :companies

  has_many :credential_assignments, through: :tickets, as: :tickets_assignments
  has_many :credential_assignments, through: :gtags, as: :gtags_assignments

  has_many :preevent_items
  has_many :credits, through: :preevent_items, source: :purchasable, source_type: "Credit"

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_attached_file :logo,
                    path: "#{Rails.application.secrets.s3_images_folder}/event/:id/logos/:filename",
                    url: "#{Rails.application.secrets.s3_images_folder}/event/:id/logos/:basename.:extension",
                    default_url: ":default_event_image_url"

  has_attached_file :background,
                    path: "#{Rails.application.secrets.s3_images_folder}/event/:id/backgrounds/:filename",
                    url: "#{Rails.application.secrets.s3_images_folder}/event/:id/backgrounds/:basename.:extension",
                    default_url: ":default_event_background_url"

  # Hooks
  before_create :generate_token

  # Validations
  validates :name, :support_email, presence: true
  validates :name, uniqueness: true
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}

  # State machine
  include EventState

  def self.background_types_selector
    BACKGROUND_TYPES.map { |f| [I18n.t("admin.event.background_types." + f.to_s), f] }
  end

  def self.payment_services_selector
    PAYMENT_SERVICES.map { |f| [I18n.t("admin.event.payment_services." + f.to_s), f] }
  end

  def self.refund_services_selector
    REFUND_SERVICES.map { |f| [I18n.t("admin.event.refund_services." + f.to_s), f] }
  end

  def standard_credit
    credits.find_by(standard: true)
  end

  def standard_credit_price
    PreeventProduct.find(credits.standard_credit_preevent_product(event_id: id)).rounded_price
  end

  def total_credits
    gtags.joins(:gtag_credit_log).sum(:amount)
  end

  def total_refundable_money(refund_service)
    fee = refund_fee(refund_service)
    minimun = refund_minimun(refund_service)
    standard_price = standard_credit_price
    gtag_assignments
      .joins(:gtag, gtag: :gtag_credit_log)
      .where(aasm_state: :assigned)
      .where("((amount * #{standard_price}) - #{fee}) >= #{minimun}")
      .where("((amount * #{standard_price}) - #{fee}) > 0")
      .sum("(amount * #{standard_price}) - #{fee}")
  end

  def total_refundable_gtags(refund_service)
    fee = refund_fee(refund_service)
    minimun = refund_minimun(refund_service)
    gtag_assignments
      .joins(:gtag, gtag: :gtag_credit_log)
      .where(aasm_state: :assigned)
      .where("((amount * #{standard_credit_price}) - #{fee}) >= #{minimun}")
      .where("((amount * #{standard_credit_price}) - #{fee}) > 0")
      .count
  end

  # TODO: Improve with decorators
  def get_parameter(category, group, name)
    parameter = Parameter.find_by(category: category, group: group, name: name)
    EventParameter.find_by(event_id: id, parameter_id: parameter.id).value
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

  def generate_token
    loop do
      self.token = SecureRandom.hex
      break unless self.class.exists?(token: token)
    end
  end
end
