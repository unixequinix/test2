module Creators
  class GtagJob < Base
    queue_as :medium

    def perform(event, uid, balance = 0, atts = {})
      return if uid.blank?

      gtag = create_gtag(uid, event)
      gtag.update!(atts)

      next unless balance.to_f.positive?
      customer = gtag.customer || event.customers.create!
      gtag.update!(customer: customer)
      OrderCreator.perform_later(event, customer, balance)
    end
  end
end
