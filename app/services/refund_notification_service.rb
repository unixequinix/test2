class RefundNotificationService
  def notify(event)
    notify_customers_to(event) if event.claiming_started?
  end

  private

  def notify_customers_to(event)
    GtagRegistration.includes(:customer_event_profile).where(aasm_state: :assigned).each do |gtag_registration|
      send_mail_to(gtag_registration.customer_event_profile, event)
    end
  end

  def send_mail_to(customer_event_profile, event)
    ClaimMailer.notification_email(customer_event_profile, event).deliver_later
  end
end