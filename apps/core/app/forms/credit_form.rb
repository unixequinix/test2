class CreditForm < CredentiableForm

  attribute :value, Decimal
  attribute :currency, String
  attribute :standard, Boolean, default: false
  validates_presence_of :value
  validates_presence_of :currency

  def save
    @credit = Credit.new(catalog_item_attributes: { name: name,
                                                   description: description,
                                                   step: step,
                                                   initial_amount: initial_amount,
                                                   max_purchasable: max_purchasable,
                                                   min_purchasable: min_purchasable,
                                                   event_id: event_id
                                                 },
                        value: value,
                        currency: currency,
                        standard: standard
                       )
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    @credit.catalog_item.credential_type = CredentialType.new if create_credential_type
    @credit.save
  end
end