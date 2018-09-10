module Creators
  class GtagJob < Base
    queue_as :medium

    def perform(event, uid, balance = 0, virtual_balance = 0, atts = {})
      return if uid.blank?

      gtag = create_gtag(uid, event, atts)

      return unless balance.to_f.positive? || virtual_balance.to_f.positive?
      customer = gtag.customer || event.customers.create!
      gtag.update!(customer: customer)
      Creators::OrderJob.perform_later(event, customer, balance, virtual_balance)
    end
  end
end
