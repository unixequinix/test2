class EditAdminForm < Reform::Form
  include ActiveModel::ModelReflections

  property :email, on: :admin
  property :encrypted_password, on: :admin
  property :password, virtual: true
  property :current_password, virtual: true

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validate :current_password_same_as_password
  validate :email_uniqueness

  model :admin

  def admin
    model[:admin]
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
      email != model.email && Admin.exists?(email: email)
  end
end
