module Creators
  class GtagJob < ApplicationJob
    queue_as :medium

    def perform(event, uid, customer, balance = 0, atts = {})
      return if uid.blank?

      begin
        gtag = event.gtags.find_or_create_by(tag_uid: uid)
        gtag.update!(atts.merge(customer: customer))
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      OrderCreator.perform_later(event, customer, balance) if balance.to_f.positive?
    end
  end
end
