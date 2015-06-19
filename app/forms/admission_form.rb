# See: http://www.vanderpol.net/cleaning-rails-app-signup-devise-reform/
class AdmissionForm < Reform::Form
  include Composition
  include ModelReflections

  property :email, on: :customer, validates: { presence: true }
  property :name, on: :customer, validates: { presence: true }
  property :surname, on: :customer, validates: { presence: true }
  property :password, on: :customer, validates: { presence: true }
  property :agreed_on_registration, on: :customer
  property :event_id, on: :admission, validates: { presence: true }

  model :admission

  validates_acceptance_of :agreed_on_registration

  def save
    return false unless valid?
    sync
    puts "AFTER SYNC"
    puts model[:customer].inspect
    admission = model[:admission]
    admission.customer = fetch_or_create_customer
    admission.save
  end

  private

  def fetch_or_create_customer
    customer = Customer.find_by(email: email) || model[:customer]
    customer.save unless customer.persisted?
    puts "ERRORS!!!!"
    puts customer.errors.inspect
    customer
  end
end
