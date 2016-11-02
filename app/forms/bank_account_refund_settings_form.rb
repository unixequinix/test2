class BankAccountRefundSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :action_name, String
  attribute :fee, Decimal
  attribute :minimum, Decimal
  attribute :validate_sepa, String
  attribute :area, String
  attribute :event_id, Integer

  validates :action_name, presence: true
  validates :fee, presence: true
  validates :minimum, presence: true
  validates :area, presence: true
  validates :event_id, presence: true
  validates_inclusion_of :validate_sepa, in: %w(true false)

  validates :fee, numericality: true
  validates :minimum, numericality: true

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
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end
