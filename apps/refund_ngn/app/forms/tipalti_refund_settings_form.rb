class TipaltiRefundSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :fee, Decimal
  attribute :minimum, Decimal
  attribute :event_id, Integer
  attribute :payer, String
  attribute :idap, String
  attribute :secret_key, String
  attribute :url, String

  validates_presence_of :fee
  validates_presence_of :minimum
  validates_presence_of :event_id
  validates_presence_of :payer
  validates_presence_of :idap
  validates_presence_of :secret_key
  validates_presence_of :url

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
    Parameter.where(category: 'refund', group: 'tipalti').each do |parameter|
      ep = EventParameter.find_by(event_id: event_id, parameter_id: parameter.id)
      ep.nil? ? EventParameter.create!(value: attributes[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) : ep.update(value: attributes[parameter.name.to_sym])
    end
  end

end