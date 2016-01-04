class BankAccountRefundSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :action_name, String
  attribute :fee, Decimal
  attribute :minimum, Decimal
  attribute :validate_sepa, String
  attribute :area, String
  attribute :event_id, Integer

  validates_presence_of :action_name
  validates_presence_of :fee
  validates_presence_of :minimum
  validates_presence_of :area
  validates_presence_of :event_id
  validates_inclusion_of :validate_sepa, in: %w(true false)

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
    Parameter.where(category: "refund", group: "bank_account").each do |parameter|
      eps = EventParameter.find_by(event_id: event_id, parameter_id: parameter.id)
      eps.nil? ? EventParameter.create!(value: attributes[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) : eps.update(value: attributes[parameter.name.to_sym])
    end
  end
end
