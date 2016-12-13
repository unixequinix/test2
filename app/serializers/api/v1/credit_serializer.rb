class Api::V1::CreditSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :value, :currency

  def currency
    object.event.currency
  end
end
