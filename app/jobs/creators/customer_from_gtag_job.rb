module Creators
  class CustomerFromGtagJob < Base
    queue_as :medium

    def perform(old_gtag, new_event, balance_selection) # rubocop:disable Metrics/PerceivedComplexity
      gtag = create_gtag(old_gtag.tag_uid, new_event, old_gtag.attributes.slice('banned', 'format', 'active'))
      old_customer = old_gtag&.customer

      customer = if old_customer&.registered?
                   copy_customer(old_customer, new_event)
                 elsif old_customer&.anonymous?
                   new_event.gtags.where(tag_uid: (old_customer.gtags.pluck(:tag_uid) - [gtag.tag_uid]))&.first&.customer || new_event.customers.create!
                 else
                   new_event.customers.create!
                 end

      gtag.update!(customer: customer)

      balance = old_customer&.credits.to_f
      virtual_balance = balance_selection.to_i.zero? ? balance_selection.to_f : old_customer&.virtual_credits.to_f

      Creators::OrderJob.perform_later(new_event, customer, balance, virtual_balance) if balance.positive? || virtual_balance.positive?
    end
  end
end
