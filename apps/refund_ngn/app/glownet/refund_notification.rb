class RefundNotification
  def notify(event)
    notify_customers_to(event) if event.finished?
  end

  private

  def notify_customers_to(event)
    CustomerEventProfile.with_gtag(event).all? { |profile| send_mail_to(profile, event) }
  end

  def send_mail_to(customer_event_profile, event)
    ClaimMailer.notification_email(customer_event_profile, event).deliver_later
  end
end
