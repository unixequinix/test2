class EditProfileForm < Reform::Form
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
  property :encrypted_password, on: :customer
  property :password, virtual: true
  property :current_password, virtual: true

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :event_id, :email, :first_name, :last_name, :current_password, presence: true
  # :phone, :address, :city, :country, :postcode, :gender, :birthdate
  validate :current_password_same_as_password
  validate :email_uniqueness

  model :customer

  def customer
    model[:customer]
  end

  def sync
    self.password = current_password if password.empty?
    super
    model.encrypted_password = Authentication::Encryptor.digest(password)
  end

  def current_password_same_as_password
    errors[:current_password] <<
      I18n.t("auth.failure.invalid_current_password") unless
      Authentication::Encryptor.compare(model.encrypted_password, current_password)
  end

  def email_uniqueness
    errors[:email] <<
      I18n.t("activerecord.errors.models.customer.attributes.email.taken") if
      email != model.email &&
      Customer.exists?(email: email.downcase, event_id: event_id, deleted_at: nil)
  end

  def autotopup_amounts(payment_gateway)
    amount = current_autotopup_amount(payment_gateway)
    (PaymentGatewayCustomer::AUTOTOPUP_AMOUNTS + [amount]).uniq.sort
  end

  def current_autotopup_amount(payment_gateway)
    payment_gateway.autotopup_amount
  end
end
