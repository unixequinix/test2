module Creators
  class FeeJob < Base
    queue_as :default

    def perform(event, customer, gateway = "previous_initial_fee")
      return if customer.orders.find_by(gateway: "previous_initial_fee").present?

      orders = []
      orders << [event.user_flags.find_by(name: "initial_topup").id, 1]

      customer.build_order(orders).complete!(gateway) if orders.any?
    end
  end
end
