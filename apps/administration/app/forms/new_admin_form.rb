class NewAdminForm < Reform::Form
  include ActiveModel::ModelReflections

  property :email, on: :admin
  property :encrypted_password, on: :admin
  property :password, virtual: true

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validate :email_uniqueness

  model :admin

  def admin
    model[:admin]
  end

  def sync
    super
    model.encrypted_password = Authentication::Encryptor.digest(password)
  end

  def email_uniqueness
    errors[:email] <<
      I18n.t("activerecord.errors.models.customer.attributes.email.taken") if
      Admin.exists?(email: email)
  end
end
