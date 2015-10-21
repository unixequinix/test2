class BankAccountRefundSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :fee, Decimal
  attribute :minimum, Decimal
  attribute :event_id, Integer
  attribute :refund_success_message
  attribute :mass_email_claim_notification

  validates_presence_of :fee
  validates_presence_of :minimum
  validates_presence_of :event_id
  validates_presence_of :refund_success_message
  validates_presence_of :mass_email_claim_notification

  validates_numericality_of :fee

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
    Parameter.where(category: 'refund', group: 'bank_account').each do |parameter|
      eps = EventParameter.find_by(event_id: event_id, parameter_id: parameter.id)
      eps.nil? ? EventParameter.create!(value: attributes[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) : eps.update(value: attributes[parameter.name.to_sym])
    end
  end

end