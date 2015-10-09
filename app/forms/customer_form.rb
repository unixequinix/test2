class CustomerForm
  include ActiveModel::Model
  include Virtus.model

  attribute :email, String
  attribute :name, String
  attribute :surname, String
  attribute :password, String
  attribute :phone, String
  attribute :postcode, String
  attribute :address, String
  attribute :city, String
  attribute :country, String
  attribute :gender, String
  attribute :birthdate, DateTime
  attribute :agreed_on_registration, Boolean

  def initialize(params=nil)
    @customer = Customer.new(params) if params
  end

  def save
    if @customer.valid?
      persist!
      true
    else
      false
    end
  end

  def customer
    @customer
  end

  def persist!
    @customer.skip_confirmation_notification!
    @customer.save
  end
end