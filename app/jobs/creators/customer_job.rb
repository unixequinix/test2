module Creators
  class CustomerJob < Base
    queue_as :medium

    def perform(old_customer, event)
      customer = copy_customer(old_customer, event)

      balance = old_customer&.global_refundable_credits&.to_f
      Creators::OrderJob.perform_later(event, customer, balance) if balance.to_f.positive?
    end
  end
end
