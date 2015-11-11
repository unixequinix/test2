class RedsysPaymentSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, String
  attribute :code, String
  attribute :terminal, String
  attribute :password, String
  attribute :currency, String
  attribute :transaction_type, String
  attribute :pay_methods, String
  attribute :ip, String
  attribute :form, String
  attribute :event_id, Integer

  validates_presence_of :name
  validates_presence_of :code
  validates_presence_of :terminal
  validates_presence_of :password
  validates_presence_of :currency
  validates_presence_of :transaction_type
  validates_presence_of :pay_methods
  validates_presence_of :ip
  validates_presence_of :form
  validates_presence_of :event_id

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    Parameter.where(category: 'payment', group: 'redsys').each do |parameter|
      ep = EventParameter.find_by(event_id: event_id, parameter_id: parameter.id)
      ep.nil? ? EventParameter.create!(value: attributes[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) : ep.update(value: attributes[parameter.name.to_sym])
    end
  end

end