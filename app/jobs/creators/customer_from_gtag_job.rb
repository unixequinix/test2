module Creators
  class CustomerFromGtagJob < Base
    queue_as :medium

    def perform(old_gtag, new_event)
      gtag = create_gtag(old_gtag.tag_uid, new_event)
      old_customer = old_gtag.customer
      customer = gtag.customer || copy_customer(old_customer, new_event)

      gtag.update!(customer: customer)

      balance = old_customer&.global_refundable_credits&.to_f
      Creators::OrderJob.perform_later(new_event, customer, balance) if balance.positive?
    end
  end
end