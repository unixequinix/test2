module Creators
  class CustomerJob < Base
    queue_as :medium

    def perform(old_customer, event)
      customer = copy_customer(old_customer, event)

      balance = old_customer&.credits.to_f
      virtual_balance = old_customer&.virtual_credits.to_f

      Creators::OrderJob.perform_later(event, customer, balance, virtual_balance) if balance.positive? || virtual_balance.positive?
    end
  end
end
