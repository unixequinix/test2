class CustomerLoginForm < Reform::Form
  include ActiveModel::ModelReflections

  property :event_id, on: :customer
  property :email, on: :customer
  property :encrypted_password, on: :customer
  property :password, virtual: true
  property :remember_me, virtual: true

  validates :event_id, :email, :password, presence: true
  validate :correct_password

  model :customer

  def customer
    model[:customer]
  end

  def correct_password
    errors[:password_confirmation] <<
      I18n.t('auth.failure.invalid_current_password') if
      !Authentication::Encryptor.compare(model.encrypted_password, password)
  end

end
