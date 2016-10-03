class ResetPasswordForm < Reform::Form
  include ActiveModel::ModelReflections

  property :event_id, on: :customer
  property :email, on: :customer
  property :encrypted_password, on: :customer
  property :reset_password_token, on: :customer
  property :reset_password_sent_at, on: :customer
  property :password, virtual: true
  property :password_confirmation, virtual: true

  validates :event_id, :email, :password, :password_confirmation, presence: true
  validate :equal_passwords

  model :customer

  def customer
    model[:customer]
  end

  def sync
    super
    model.encrypted_password = Authentication::Encryptor.digest(password)
    model.reset_password_token = nil
    model.reset_password_sent_at = nil
  end

  def equal_passwords
    errors[:password_confirmation] <<
      I18n.t("auth.failure.invalid_current_password") if
      password != password_confirmation
  end
end
