module Api::V2
  class TransactionSerializer < ActiveModel::Serializer
    attributes :id, :action, :gtag_id, :station_id, :credits, :refundable_credits, :final_balance, :final_refundable_balance, :sale_items

    def credits
      object.credits || object.payments[object.event.credit.id.to_s].to_h["amount"].to_f + object.payments[object.event.virtual_credit.id.to_s].to_h["amount"].to_f
    end

    def refundable_credits
      object.refundable_credits || object.payments[object.event.credit.id.to_s].to_h["amount"].to_f
    end

    def final_balance
      object.final_balance || object.payments[object.event.credit.id.to_s].to_h["final_balance"].to_f + object.payments[object.event.virtual_credit.id.to_s].to_h["final_balance"].to_f
    end

    def final_refundable_balance
      object.final_refundable_balance || object.payments[object.event.credit.id.to_s].to_h["final_balance"].to_f
    end
  end
end
