module Creators
  class Base < ApplicationJob
    CUSTOMER_ATTS = %w[id event_id created_at updated_at remember_token reset_password_token confirmation_token].freeze
    GTAG_ATTS = %w[created_at updated_at tag_uid event_id customer_id id].freeze

    protected

    def copy_customer(old_customer, new_event)
      customer_atts = old_customer&.attributes&.except!(*CUSTOMER_ATTS)&.to_h
      new_event.customers.find_or_create_by(customer_atts)
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def create_gtag(uid, event, atts = {})
      gtag = event.gtags.find_or_create_by(tag_uid: uid)
      gtag.update!(atts.except!(*GTAG_ATTS))
      gtag
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
