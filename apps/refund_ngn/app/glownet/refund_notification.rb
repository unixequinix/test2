class RefundNotification
  def notify(event)
    notify_customers_to(event) if event.claiming_started?
  end

  private

  def notify_customers_to(event)
    sent = false
    CustomerEventProfile.with_gtag(event).each do |customer_event_profile|
      sent = true if send_mail_to(customer_event_profile, event)
    end
    sent
  end

  def send_mail_to(customer_event_profile, event)
    ClaimMailer.notification_email(customer_event_profile, event).deliver_later
  end
end
