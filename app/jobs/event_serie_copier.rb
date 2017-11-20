class EventSerieCopier < ApplicationJob
  CUSTOMER_ATTS = %w[id event_id created_at updated_at remember_token reset_password_token confirmation_token].freeze

  def perform(new_event, old_event, selection)
    customers = old_event.customers.where(anonymous: selection).includes(:gtags)

    customers.each do |old_customer|
      if old_customer.anonymous?
        customer = new_event.customers.create!
      else
        customer_atts = old_customer.attributes.except!(*CUSTOMER_ATTS)
        customer = new_event.customers.find_or_initialize_by(customer_atts)
        customer.save(validate: false)
      end

      old_customer.gtags.each { |gtag| Creators::GtagJob.perform_later(new_event, gtag.tag_uid, customer) }
      Creators::OrderJob.perform_later(new_event, customer, old_customer.global_refundable_credits)
    end
  end
end
