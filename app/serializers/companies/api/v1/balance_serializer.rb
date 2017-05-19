class Companies::Api::V1::BalanceSerializer < Companies::Api::V1::BaseSerializer
  attributes :tag_uid, :balance, :currency

  def balance
    object.customer.global_credits
  end

  def currency
    object.event.credit.name
  end
end
