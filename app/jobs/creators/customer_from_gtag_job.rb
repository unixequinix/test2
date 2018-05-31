module Creators
  class CustomerFromGtagJob < Base
    queue_as :medium

    def perform(old_gtag, new_event, balance_selection) # rubocop:disable Metrics/PerceivedComplexity
      old_customer = old_gtag&.customer

      gtags = if old_gtag&.customer&.gtags&.count.to_i.positive?
                old_customer.gtags.map { |g| create_gtag(g.tag_uid, new_event, g.attributes.slice('banned', 'format', 'active')) }
              else
                create_gtag(old_gtag.tag_uid, new_event, old_gtag.attributes.slice('banned', 'format', 'active'))
              end

      customer = if old_customer&.registered?
                   copy_customer(old_customer, new_event)
                 elsif old_customer&.anonymous?
                   customers = new_event.customers.includes(:gtags).where(gtags: { id: gtags })

                   customers.any? ? customers.last : new_event.customers.create!
                 end

      new_event.gtags.where(id: gtags).update_all(customer_id: customer.id) if customer.present?

      balance = old_customer&.credits.to_f
      virtual_balance = balance_selection.to_i.zero? ? balance_selection.to_f : old_customer&.virtual_credits.to_f
      create_conditions = ((balance.positive? || virtual_balance.positive?) && customer.present?)

      Creators::OrderJob.perform_later(new_event, customer, balance, virtual_balance) if create_conditions
    end
  end
end
