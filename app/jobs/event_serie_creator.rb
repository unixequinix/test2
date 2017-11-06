class EventSerieCreator < ApplicationJob
  def perform(current_event, base_event, selection)
    return if base_event.blank?

    selection = ActiveModel::Type::Boolean.new.cast(selection)

    begin
      customers = selection.nil? ? base_event.customers : base_event.customers.where(anonymous: selection)

      copy_gtags(customers, current_event)
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  private

  def copy_gtags(customers, current_event) # rubocop:disable Metrics/MethodLength
    customers.includes(:gtags).each do |base_customer|
      base_customer_atts = base_customer.attributes.except!(
        "id",
        "event_id",
        "created_at",
        "updated_at",
        "remember_token",
        "reset_password_token",
        "confirmation_token"
      )

      customer = current_event.customers.find_by(email: base_customer_atts['email'])

      unless customer
        customer = current_event.customers.build(base_customer_atts)
        customer.skip_password_validation = true
        customer.save!
      end

      begin
        base_customer.gtags.each do |base_gtag|
          next if base_gtag.tag_uid.size != 14
          gtag = current_event.gtags.find_or_create_by!(tag_uid: base_gtag.tag_uid)
          gtag.update!(customer: customer, active: base_gtag.active?)
        end

        next unless create_orders(base_customer, customer)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end
  end

  def create_orders(base_customer, customer)
    balance = base_customer.global_refundable_credits - customer.global_refundable_credits
    return false if balance.negative? || balance.zero?

    order = customer.build_order [[customer.event.credit.id, balance]]
    order.update!(status: "completed", gateway: "previous_balance", completed_at: Time.zone.now)

    atts = { payment_method: "previous_balance", payment_gateway: "previous_balance", order_id: order.id, price: order.total }
    MoneyTransaction.write!(customer.event, "portal_purchase", :portal, customer, customer, atts)

    true
  end
end
