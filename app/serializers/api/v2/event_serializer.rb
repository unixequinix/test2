module Api::V2
  class EventSerializer < ActiveModel::Serializer
    attributes :id, :name, :slug, :logo, :background, :currency, :state, :open_topups, :open_refunds, :every_topup_fee, :onsite_initial_topup_fee, :online_initial_topup_fee, :gtag_deposit_fee, :refund_fee, :maximum_gtag_balance

    attribute :credit

    def credit
      Api::V2::CreditSerializer.new(object.credit)
    end
  end
end
