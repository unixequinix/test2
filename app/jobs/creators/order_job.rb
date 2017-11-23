module Creators
  class OrderJob < Base
    queue_as :medium

    def perform(event, customer, balance)
      credits = balance.to_f
      return if credits.zero? || credits.negative? || customer.orders.find_by(gateway: "previous_balance").present?

      customer.build_order([[event.credit.id, credits]]).complete!("previous_balance")
    end
  end
end
