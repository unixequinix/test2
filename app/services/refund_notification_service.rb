class RefundNotificationService
  def notify(event)
    notify_customers_to(event) if event.claiming_started?
  end

  private

  def notify_customers_to(event)
    GtagRegistration.includes(:customer).where(aasm_state: :assigned).each do |gtag_registration|
      send_mail_to(gtag_registration.customer, event)
    end
  end

  def send_mail_to(customer, event)
    puts customer.to_json
    puts event.to_json
    ClaimMailer.notification_email(customer, event).deliver_later
  end
end