module Creators
  class GtagJob < Base
    queue_as :medium

    def perform(event, uid, balance = 0, atts = {})
      return if uid.blank?

      gtag = create_gtag(uid, event, atts)

      return unless balance.to_f.positive?
      customer = gtag.customer || event.customers.create!
      gtag.update!(customer: customer)
      OrderJob.perform_later(event, customer, balance)
    end
  end
end
