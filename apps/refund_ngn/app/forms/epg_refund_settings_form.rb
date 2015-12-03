class EpgRefundSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :action_name, String
  attribute :fee, Decimal
  attribute :minimum, Decimal
  attribute :country, String
  attribute :currency, String
  attribute :operation_type, String
  attribute :payment_solution, String
  attribute :md5key, String
  attribute :merchant_id, String
  attribute :product_id, String
  attribute :url, String
  attribute :event_id, Integer

  validates_presence_of :action_name
  validates_presence_of :fee
  validates_presence_of :minimum
  validates_presence_of :country
  validates_presence_of :currency
  validates_presence_of :operation_type
  validates_presence_of :payment_solution
  validates_presence_of :md5key
  validates_presence_of :merchant_id
  validates_presence_of :product_id
  validates_presence_of :url
  validates_presence_of :event_id

  validates_numericality_of :fee
  validates_numericality_of :minimum

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
    Parameter.where(category: 'refund', group: 'epg').each do |parameter|
      ep = EventParameter.find_by(event_id: event_id, parameter_id: parameter.id)
      ep.nil? ? EventParameter.create!(value: attributes[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) : ep.update(value: attributes[parameter.name.to_sym])
    end
  end

end