module Creators
  class Base < ApplicationJob
    protected

    def copy_customer(old_customer, new_event)
      excluded_atts = %w[id event_id created_at updated_at remember_token reset_password_token confirmation_token]
      customer_atts = old_customer&.attributes&.except!(*excluded_atts)&.to_h
      customer = new_event.customers.find_or_initialize_by(customer_atts)
      customer.skip_password_validation = true
      customer.save!
      customer
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def create_gtag(uid, event)
      event.gtags.find_or_create_by(tag_uid: uid)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
