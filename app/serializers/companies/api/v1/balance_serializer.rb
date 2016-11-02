class Companies::Api::V1::BalanceSerializer < Companies::Api::V1::BaseSerializer
  attributes :tag_uid, :balance, :currency

  def balance
    object.profile.credits
  end

  def currency
    object.event.token_symbol
  end
end
