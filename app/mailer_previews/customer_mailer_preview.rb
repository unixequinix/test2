class CustomerMailerPreview < ActionMailer::Preview
  def reset_password_instructions_email
    CustomerMailer.reset_password_instructions_email(Customer.first)
  end

  def completed_order_email
    customer = Customer.first || FactoryGirl.create(:customer, event: Event.first)
    order = FactoryGirl.create(:order, customer: customer)
    order.update!(completed_at: Time.zone.now)
    order.order_items.create(amount: 10, total: 20, catalog_item: CatalogItem.first)
    CustomerMailer.completed_order_email(order, Event.first)
  end
end
