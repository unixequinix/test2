class GtagSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :format, String
  attribute :event_id, Integer
  attribute :gtag_name, String
  attribute :gtag_type, String
  attribute :maximum_gtag_balance, Float
  attribute :cards_can_refund, String
  attribute :gtag_form_disclaimer
  attribute :gtag_assignation_notification
  attribute :gtag_deposit

  validates_presence_of :format
  validates_presence_of :event_id
  validates_presence_of :gtag_name
  validates_presence_of :gtag_type
  validates_presence_of :cards_can_refund
  validates_numericality_of :maximum_gtag_balance
  validates_numericality_of :gtag_deposit

  validate :enough_space_for_credential
  validate :enough_space_for_entitlements

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def gtag_uid_formats
    Gtag::UID_FORMATS
  end

  private

  def persist!
    Parameter.where(category: "gtag", group: "form").each do |parameter|
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.update(value: attributes[parameter.name.to_sym])
    end
  end

  def enough_space_for_credential
    limit = Gtag.field_by_name name: gtag_type, field: :credential_limit
    last_credential = CredentialType.joins(:catalog_item)
                                    .where(catalog_items: { event_id: event_id })
                                    .order("memory_position DESC").first
    last_credential_position = last_credential.present? ? last_credential.memory_position : 0

    return if last_credential_position <= limit
    errors[:gtag_type] << I18n.t("errors.messages.not_enough_space_for_credential_configuration")
  end

  def enough_space_for_entitlements
    limit = Gtag.field_by_name name: gtag_type, field: :entitlement_limit
    last_entitlement = Entitlement.where(event_id: event_id).order("memory_position DESC").first
    last_entitlement_position = last_entitlement.present? ? last_entitlement.memory_position : 0
    return if last_entitlement_position <= limit
    errors[:gtag_type] << I18n.t("errors.messages.not_enough_space_for_entitlement_configuration")
  end
end
