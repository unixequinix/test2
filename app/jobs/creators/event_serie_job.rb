module Creators
  class EventSerieJob < Base
    def perform(new_event, old_event, customers_selection, gtags_selection = "0")
      customers = old_event.customers.where(anonymous: customers_selection)

      gtags = old_event.gtags.where(customer: customers)
      gtags.each { |gtag| CustomerFromGtagJob.perform_later(gtag, new_event) }

      registered = customers.where.not(id: gtags.pluck(:customer_id)).reject(&:anonymous?)
      registered.each { |customer| CustomerJob.perform_later(customer, new_event) }

      return unless gtags_selection.eql?("1")
      gtags = old_event.gtags.where(customer: nil)
      gtags.each { |gtag| CustomerFromGtagJob.perform_later(gtag, new_event) }
    end
  end
end
