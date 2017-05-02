class OrderMailerPreview < ActionMailer::Preview
  def completed_order_email
    event = Event.first || FactoryGirl.create(:event)
    customer = event.customers.first || FactoryGirl.create(:customer, event: event)
    order = FactoryGirl.create(:order, customer: customer, event: event)
    order.update!(completed_at: Time.zone.now)
    order.order_items.create(amount: 10, total: 20, catalog_item: event.credit)
    OrderMailer.completed_order_email(order)
  end

  def completed_refund_email
    customer = Customer.first || FactoryGirl.create(:customer, event: Event.first)
    refund = FactoryGirl.create(:refund, customer: customer)
    OrderMailer.completed_refund_email(refund, Event.first)
  end
end
