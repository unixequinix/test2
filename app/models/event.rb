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
#  refund_service          :string           default("bank_account")
#  gtag_registration       :boolean          default(TRUE), not null
#

class Event < ActiveRecord::Base
  nilify_blanks
  translates :info, :disclaimer, :refund_success_message, :mass_email_claim_notification, :gtag_assignation_notification, :gtag_form_disclaimer, :gtag_name, fallbacks_for_empty_translations: true

  #Background Types
  BACKGROUND_FIXED = 'fixed'
  BACKGROUND_REPEAT = 'repeat'

  BACKGROUND_TYPES = [BACKGROUND_FIXED, BACKGROUND_REPEAT]


  #Refund Services
  BANK_ACCOUNT = 'bank_account'
  EASY_PAYMENT_GATEWAY = 'epg'

  REFUND_SERVICES = [BANK_ACCOUNT, EASY_PAYMENT_GATEWAY]

  include FlagShihTzu

  has_flags 1 => :ticketing,
            2 => :refunds,
            column: 'features'

  FEATURES = [:ticketing, :refunds]

  # Associations
  has_many :customer_event_profiles
  has_many :entitlements
  has_many :ticket_types
  has_many :tickets
  has_many :admissions, through: :tickets
  has_many :gtags
  has_many :gtag_registrations, through: :gtags
  has_many :online_products
  has_many :credits, through: :online_products, source: :purchasable, source_type: "Credit"
  has_one :standard_credit, -> { credits.where(standard: true)}

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_attached_file :logo,
                    path: "#{Rails.application.secrets.s3_images_folder}/event/:id/logos/:filename",
                    url: "#{Rails.application.secrets.s3_images_folder}/event/:id/logos/:basename.:extension",
                    default_url: ':default_event_image_url'

  has_attached_file :background,
                    path: "#{Rails.application.secrets.s3_images_folder}/event/:id/backgrounds/:filename",
                    url: "#{Rails.application.secrets.s3_images_folder}/event/:id/backgrounds/:basename.:extension",
                    default_url: ':default_event_background_url'

  # Association
  has_many :event_parameters

  # Validations
  validates :name, :support_email, presence: true
  validates :name, uniqueness: true
  validates_attachment_content_type :logo, content_type: %r{\Aimage/.*\Z}
  validates_attachment_content_type :background, content_type: %r{\Aimage/.*\Z}

  # State machine
  include AASM

  aasm do
    state :created, initial: true
    state :launched
    state :started
    state :finished
    state :claiming_started
    state :closed

    event :launch do
      transitions from: :created, to: :launched
    end

    event :start do
      transitions from: :launched, to: :started
    end

    event :finish do
      transitions from: :started, to: :finished
    end

    event :start_claim do
      transitions from: :finished, to: :claiming_started
    end

    event :close do
      transitions from: :claiming_started, to: :closed
    end

    event :reboot do
      transitions from: :closed, to: :created
    end
  end

  # Methods
  # -------------------------------------------------------

  def self.background_types_selector
    BACKGROUND_TYPES.map { |f| [I18n.t('admin.event.background_types.' + f), f] }
  end

  def self.refund_services_selector
    REFUND_SERVICES.map { |f| [I18n.t('admin.event.refund_services.' + f), f] }
  end

  def standard_credit
    self.credits.where(standard: true).first
  end

  def standard_credit_price
    self.standard_credit.online_product.rounded_price
  end

  def total_credits
    self.gtags.joins(:gtag_credit_log).sum(:amount)
  end

  def total_refundable_money
    fee = refund_fee
    standard_price = standard_credit_price
    self.gtag_registrations
      .joins(:gtag, gtag: :gtag_credit_log)
      .where(aasm_state: :assigned)
      .where("((amount * #{standard_price}) - #{fee}) >= #{refund_minimun}")
      .where("((amount * #{standard_price}) - #{fee}) > 0")
      .sum("(amount * #{standard_price}) - #{fee}")
  end

  def total_refundable_gtags
    self.gtag_registrations
      .joins(:gtag, gtag: :gtag_credit_log)
      .where(aasm_state: :assigned)
      .where("((amount * #{standard_credit_price}) - #{refund_fee}) >= #{refund_minimun}")
      .where("((amount * #{standard_credit_price}) - #{refund_fee}) > 0")
      .count
  end

  # TODO: Improve with decorators
  def get_parameter(category, group, name)
    parameter = EventParameter.find_by(event_id: self.id, parameter_id: Parameter.find_by(category: category, group: group, name: name)).value
  end

  private

  def refund_fee
    get_parameter('refund', self.refund_service, 'fee')
  end

  def refund_minimun
    get_parameter('refund', self.refund_service, 'minimum')
  end

end
