class EventDecorator < Draper::Decorator
  delegate_all

  # Payment services
  PAYPAL = :paypal
  PAYPAL_NVP = :paypal_nvp
  REDSYS = :redsys
  STRIPE = :stripe
  BRAINTREE = :braintree
  IDEAL = :ideal
  SOFORT = :sofort
  WIRECARD = :wirecard
  PAYMENT_SERVICES = [STRIPE, PAYPAL, REDSYS, BRAINTREE, PAYPAL_NVP, IDEAL, SOFORT, WIRECARD].freeze
  AUTOTOPUP_PAYMENT_SERVICES = [PAYPAL, PAYPAL_NVP].freeze
  PAYMENT_PLATFORMS = { paypal_nvp: "paypal_nvp",
                        paypal: "braintree",
                        braintree: "braintree",
                        redsys: "redsys",
                        ideal: "wirecard",
                        sofort: "wirecard",
                        wirecard: "wirecard",
                        stripe: "stripe" }.freeze

  REFUND_SERVICES = [:bank_account, :epg, :tipalti, :direct].freeze
  FEATURES = [:top_ups, :refunds].freeze
  LOCALES = [:en_lang, :es_lang, :it_lang, :th_lang, :de_lang].freeze
  REGISTRATION_PARAMETERS = [:phone, :address, :city, :country, :postcode, :gender,
                             :birthdate, :agreed_event_condition].freeze

  # Background Types
  BACKGROUND_FIXED = "fixed".freeze
  BACKGROUND_REPEAT = "repeat".freeze
  BACKGROUND_TYPES = [BACKGROUND_FIXED, BACKGROUND_REPEAT].freeze

  GTAG_TYPES = Gtag::GTAG_DEFINITIONS.map { |definition| definition[:name] }

  def background_fixed?
    object.background_type.eql? BACKGROUND_FIXED
  end

  def background_repeat?
    object.background_type.eql? BACKGROUND_REPEAT
  end

  def self.background_types_selector
    BACKGROUND_TYPES.map { |f| [I18n.t("admin.event.background_types." + f.to_s), f] }
  end

  def self.payment_services_selector
    PAYMENT_SERVICES.map { |f| [I18n.t("admin.event.payment_services." + f.to_s), f] }
  end

  def self.gtag_type_selector
    GTAG_TYPES.map { |f| [I18n.t("admin.gtag_settings.form." + f.to_s), f] }
  end
end
