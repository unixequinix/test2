class BankAccountRefundForm < Reform::Form
  include Composition
  include ModelReflections

  property :email, on: :customer, validates: { presence: true }
  property :name, on: :customer, validates: { presence: true }
  property :surname, on: :customer, validates: { presence: true }
  property :password, on: :customer, validates: { presence: true }
  property :password_confirmation, on: :customer, validates: { presence: true }
  property :agreed_on_registration, on: :customer, validates: { presence: true }
  property :event_id, on: :admission, validates: { presence: true }

  model :admission

  def save
    return false unless valid?
    sync
    admission = model[:admission]
    admission.customer = fetch_or_create_customer
    puts "admission.customer_ #{admission.customer}"
    admission.save
  end

  private

  def fetch_or_create_customer
    customer = Customer.find_by(email: email)
    puts "found? #{customer.inspect}"
    customer ||= model[:customer].save ? model[:customer] : Customer.none
  end
end