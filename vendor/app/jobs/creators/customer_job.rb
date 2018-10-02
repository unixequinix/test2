module Creators
  class CustomerJob < Base
    queue_as :default

    def perform(old_customer, event, balance_selection, fee_selection)
      customer = copy_customer(old_customer, event)
      initial_fee = fee_selection.to_i.zero? ? false : old_customer.initial_topup_fee_paid

      balance = old_customer&.credits.to_f
      virtual_balance = balance_selection.to_i.zero? ? balance_selection.to_f : old_customer&.virtual_credits.to_f
      customer.update(initial_topup_fee_paid: initial_fee) if initial_fee

      Creators::OrderJob.perform_later(event, customer, balance, virtual_balance) if balance.positive? || virtual_balance.positive?
      Creators::FeeJob.perform_later(event, customer) if customer.initial_topup_fee_paid
    end
  end
end
