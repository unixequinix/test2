class DirectRefundSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :fee, Decimal
  attribute :minimum, Decimal
  attribute :event_id, Integer

  validates_presence_of :fee
  validates_presence_of :minimum
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
    Parameter.where(category: "refund", group: "direct").each do |parameter|
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end
