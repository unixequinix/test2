class Api::V2::CreditSerializer < ActiveModel::Serializer
  attributes :id, :name, :value, :currency, :currency_symbol
  attribute :symbol, key: :credit_symbol

  def currency
    object.event.currency
  end

  def currency_symbol
    object.event.currency_symbol
  end
end
