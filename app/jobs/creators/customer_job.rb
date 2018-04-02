module Creators
  class CustomerJob < Base
    queue_as :medium

    def perform(old_customer, event, balance_selection)
      customer = copy_customer(old_customer, event)

      balance = old_customer&.credits.to_f
      virtual_balance = balance_selection.to_i.zero? ? balance_selection.to_f : old_customer&.virtual_credits.to_f

      Creators::OrderJob.perform_later(event, customer, balance, virtual_balance) if balance.positive? || virtual_balance.positive?
    end
  end
end
