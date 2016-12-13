class OrderMailerPreview < ActionMailer::Preview
  def completed_email
    customer = Customer.first || FactoryGirl.create(:customer, event: Event.first)
    order = FactoryGirl.create(:order, customer: customer)
    order.update!(completed_at: Time.zone.now)
    order.order_items.create(amount: 10, total: 20, catalog_item: CatalogItem.first)
    OrderMailer.completed_email(order, Event.first)
  end
end
