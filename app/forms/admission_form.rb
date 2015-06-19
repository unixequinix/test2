# See: http://www.vanderpol.net/cleaning-rails-app-signup-devise-reform/
class AdmissionForm < Reform::Form
  include Composition
  include ModelReflections

  property :email, on: :customer
  property :name, on: :customer
  property :surname, on: :customer
  property :password, on: :customer
  property :agreed_on_registration, on: :customer
  property :event_id, on: :admission

  model :admission

  validates_presence_of :email
  validates_presence_of :name
  validates_presence_of :surname
  validates_presence_of :password
  validates_presence_of :event_id
  validates_acceptance_of :agreed_on_registration

  def save
    return false unless valid?
    sync
    admission = model[:admission]
    admission.customer = fetch_or_create_customer
    admission.save
  end

  private

  def fetch_or_create_customer
    customer = Customer.find_by(email: email) || model[:customer]
    customer.save unless customer.persisted?
    customer
  end
end
