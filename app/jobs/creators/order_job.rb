module Creators
  class OrderJob < Base
    queue_as :medium

    def perform(event, customer, balance = 0, virtual_balance = 0, gateway = "previous_balance")
      credits = balance.to_f
      virtual_credits = virtual_balance.to_f

      return unless credits.positive? || virtual_credits.positive?
      return if customer.orders.find_by(gateway: "previous_balance").present?

      orders = []
      orders << [event.credit.id, credits] if credits.positive?
      orders << [event.virtual_credit.id, virtual_credits] if virtual_credits.positive?

      customer.build_order(orders).complete!(gateway)
    end
  end
end
