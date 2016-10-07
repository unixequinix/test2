class NewProfileForm
  include Recaptcha::Verify
  include ActiveModel::Model
  include Virtus.model

  attribute :event_id, Integer
  attribute :email, String
  attribute :first_name, String
  attribute :last_name, String
  attribute :phone, String
  attribute :address, String
  attribute :city, String
  attribute :country, String
  attribute :postcode, String
  attribute :gender, String
  attribute :birthdate, Date
  attribute :agreed_on_registration, Axiom::Types::Boolean
  attribute :agreed_event_condition, Axiom::Types::Boolean
  attribute :receive_communications, Axiom::Types::Boolean
  attribute :encrypted_password, String
  attribute :password, String
  attribute :locale, String

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :event_id, :email, :first_name, :last_name, :password, presence: true
  validates_acceptance_of :agreed_on_registration, accept: true
  validates_acceptance_of :recaptcha, accept: true
  validate :email_uniqueness
  validate :custom_inputs 

  def save
    if valid?
      persist!
      true
    else
      self.password = nil
      false
    end
  end

  private

  def custom_inputs # rubocop:disable all
    event = Event.find(event_id)
    # TODO: Refactor
    errors[:phone] << I18n.t("errors.messages.blank") if phone.blank? && event.phone?
    errors[:address] << I18n.t("errors.messages.blank") if address.blank? && event.address?
    errors[:city] << I18n.t("errors.messages.blank") if city.blank? && event.city?
    errors[:country] << I18n.t("errors.messages.blank") if country.blank? && event.country?
    errors[:postcode] << I18n.t("errors.messages.blank") if postcode.blank? && event.postcode?
    errors[:gender] << I18n.t("errors.messages.blank") if gender.blank? && event.gender?
    errors[:birthdate] << I18n.t("errors.messages.blank") if birthdate.blank? && event.birthdate?
    errors[:agreed_event_condition] <<
      I18n.t("errors.messages.accepted") if !agreed_event_condition && event.agreed_event_condition?
  end

  def email_uniqueness
    msg = I18n.t("activerecord.errors.models.customer.attributes.email.taken")
    errors[:email] << msg if Customer.exists?(email: email.downcase,
                                              event_id: event_id,
                                              deleted_at: nil)
  end

  def persist!
    self.encrypted_password = Authentication::Encryptor.digest(attributes.delete(:password))
    self.locale = I18n.locale
    Customer.create!(attributes.except(:password))
  end
end
