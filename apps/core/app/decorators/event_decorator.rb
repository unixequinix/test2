class EventDecorator < Draper::Decorator
  delegate_all

  REFUND_SERVICES = [:bank_account, :epg, :tipalti]
  FEATURES = [:top_ups, :refunds]
  LOCALES = [:en_lang, :es_lang, :it_lang, :th_lang]
  REGISTRATION_PARAMETERS = [:phone, :address, :city, :country, :postcode, :gender,
                             :birthdate, :agreed_event_condition]

  # Payment Services
  REDSYS = "redsys"
  STRIPE = "stripe"
  PAYMENT_SERVICES = [REDSYS, STRIPE]

  # Background Types
  BACKGROUND_FIXED = "fixed"
  BACKGROUND_REPEAT = "repeat"
  BACKGROUND_TYPES = [BACKGROUND_FIXED, BACKGROUND_REPEAT]

  GTAG_TYPES = [:mifare_classic, :ultralight_ev1]

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
