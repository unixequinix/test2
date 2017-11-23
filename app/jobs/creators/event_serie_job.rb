module Creators
  class EventSerieJob < Base
    def perform(new_event, old_event, selection)
      customers = old_event.customers.where(anonymous: selection)

      gtags = old_event.gtags.where(customer: customers)
      gtags.each { |gtag| CustomerFromGtagJob.perform_later(gtag, new_event) }

      registered = customers.where.not(id: gtags.pluck(:customer_id)).reject(&:anonymous?)
      registered.each { |customer| CustomerJob.perform_later(customer, new_event) }
    end
  end
end
