module Companies
  class BalanceSerializer < ActiveModel::Serializer
    attributes :tag_uid, :balance, :currency

    def balance
      object.customer.credits
    end

    def currency
      object.event.credit.name
    end
  end
end
