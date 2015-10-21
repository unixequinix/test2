# See: http://www.vanderpol.net/cleaning-rails-app-signup-devise-reform/
class CustomerEventProfileForm < Reform::Form
  include Composition
  include ModelReflections

  property :email, on: :customer
  property :name, on: :customer
  property :surname, on: :customer
  property :password, on: :customer
  property :agreed_on_registration, on: :customer
  property :event_id, on: :customer_event_profile

  model :customer_event_profile

  validates_presence_of :email
  validates_presence_of :name
  validates_presence_of :surname
  validates_presence_of :password
  validates_presence_of :event_id
  validates :agreed_on_registration, acceptance: true

  def save
    return false unless valid?
    sync
    customer_event_profile = model[:customer_event_profile]
    customer_event_profile.customer = fetch_or_create_customer
    customer_event_profile.save
  end

  def customer
    model[:customer]
  end

  private

  def fetch_or_create_customer
    customer = Customer.find_by(email: email) || model[:customer]
    customer.save unless customer.persisted?
    customer
  end
end
