module Creators
  class CustomerJob < ApplicationJob
    queue_as :medium

    def perform(event, atts, balance = 0)
      return if event.blank? || atts.symbolize_keys!.empty?

      begin
        customer = event.customers.find_or_initialize_by(email: atts[:email])
        customer.update!(atts)
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      OrderCreator.perform_later(event, customer, balance) if balance.to_f.positive?
    end
  end
end
