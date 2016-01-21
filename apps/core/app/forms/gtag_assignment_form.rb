class GtagAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :tag_uid, String
  attribute :tag_serial_number, String

  validates_presence_of :tag_uid
  validates_presence_of :tag_serial_number

  def save(fetcher, current_customer_event_profile)
    gtag = fetcher.find_by(
      tag_uid: tag_uid.strip.upcase,
      tag_serial_number: tag_serial_number.strip.upcase
    )
    if !gtag.nil?
      if valid?
        persist!(current_customer_event_profile, gtag)
        true
      else
        errors.add(:ticket_assignment, full_messages.join(". "))
        false
      end
    else
      errors.add(:ticket_assignment, I18n.t("alerts.gtag"))
    end
  end

  private

  def persist!(current_customer_event_profile, gtag)
    current_customer_event_profile.save
    @gtag_registration = current_customer_event_profile.gtag_assignment.create(credentiable: gtag)
    GtagMailer.assigned_email(@gtag_registration.credentiable).deliver_later
  end
end
