class AdmissionForm < Reform::Form
  include Composition

  property :email, on: :customer, validates { presence: true }
  property :name, on: :customer, validates { presence: true }
  property :surname, on: :customer, validates { presence: true }
  property :password, on: :customer, validates { presence: true }
  property :password_confirmation, on: :customer, validates { presence: true }
  property :agreed_on_registration, on: :customer, validates { presence: true }
  property :event_id, on: :admission, validates { presence: true }

  model :admission
end