class OrderMailerPreview < ActionMailer::Preview
  def completed_email
    order = FactoryGirl.create(:order_with_payment)
    OrderMailer.completed_email(order, Event.last)
  end
end
