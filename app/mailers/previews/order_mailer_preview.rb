class OrderMailerPreview < ActionMailer::Preview
  def completed_order_email
    event = Event.with_state("launched").first || FactoryGirl.create(:event)
    customer = event.customers.first || FactoryGirl.create(:customer, event: event)
    order = event.orders.completed.first || FactoryGirl.create(:order, customer: customer, event: event)
    order.update!(completed_at: Time.zone.now)
    order.order_items.create(amount: 10, total: 20, catalog_item: event.credit)
    OrderMailer.completed_order_email(order)
  end

  def completed_refund_email
    event = Event.with_state("launched").first || FactoryGirl.create(:event)
    customer = event.customers.first || FactoryGirl.create(:customer, event: event)
    refund = event.refunds.first || FactoryGirl.create(:refund, customer: customer, event: event)
    OrderMailer.completed_refund_email(refund)
  end
end
