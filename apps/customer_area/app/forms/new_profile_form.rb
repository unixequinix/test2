class NewProfileForm < Reform::Form
  include ActiveModel::ModelReflections

  property :event_id, on: :customer
  property :email, on: :customer
  property :first_name, on: :customer
  property :last_name, on: :customer
  property :phone, on: :customer
  property :address, on: :customer
  property :city, on: :customer
  property :country, on: :customer
  property :postcode, on: :customer
  property :gender, on: :customer
  property :birthdate, on: :customer
  property :agreed_on_registration, on: :customer
  property :agreed_event_condition, on: :customer
  property :encrypted_password, on: :customer
  property :password, virtual: true

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :event_id, :email, :first_name, :last_name, :password, presence: true
  # :phone, :address, :city, :country, :postcode, :gender, :birthdate
  validates :agreed_on_registration, acceptance: { accept: true }
  validate :email_uniqueness

  model :customer

  def customer
    model[:customer]
  end

  def sync
    super
    model.encrypted_password = Authentication::Encryptor.digest(password)
  end

  def email_uniqueness
    errors[:email] <<
      I18n.t("activerecord.errors.models.customer.attributes.email.taken") if
      Customer.exists?(email: email, event_id: event_id, deleted_at: nil)
  end
end
