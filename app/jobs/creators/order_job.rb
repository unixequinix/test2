module Creators
  class OrderJob < Base
    queue_as :medium

    def perform(event, customer, balance, gateway = "previous_balance")
      credits = balance.to_f
      return if credits.zero? || credits.negative? || customer.orders.find_by(gateway: gateway).present?

      customer.build_order([[event.credit.id, credits]], previous_balance: true).complete!(gateway)
    end
  end
end
