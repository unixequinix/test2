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
  validates :phone, presence: true, if: -> { event && event.phone? }
  validates :birthdate, presence: true, if: -> { event && event.birthdate? }
  validates :phone, presence: true, if: -> { event && event.phone? }
  validates :postcode, presence: true, if: -> { event && event.postcode? }
  validates :address, presence: true, if: -> { event && event.address? }
  validates :city, presence: true, if: -> { event && event.city? }
  validates :country, presence: true, if: -> { event && event.country? }
  validates :gender, presence: true, if: -> { event && event.gender? }

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
