class Api::V1::CreditSerializer < ActiveModel::Serializer
  attributes :id, :name, :value, :currency

  def currency
    object.event.currency
  end
end
