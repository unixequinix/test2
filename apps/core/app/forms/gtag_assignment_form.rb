class GtagAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :tag_uid, String
  attribute :tag_serial_number, String
  attribute :event_id, Integer

  validates_presence_of :tag_uid
  validates_presence_of :tag_serial_number, unless: :simple?

  def save(fetcher, profile)
    gtag = fetcher.find_by(tag_uid: tag_uid.strip.upcase,
                           tag_serial_number: tag_serial_number.to_s.strip.upcase)

    errors.add(:gtag_assignment, I18n.t("alerts.gtag.invalid")) && return if gtag.nil?
    errors.add(:gtag_assignment, I18n.t("alerts.gtag.already_assigned")) &&
      return if gtag.assigned_customer_event_profile
    errors.add(:gtag_assignment, gtag.errors.full_messages.join(". ")) && return unless valid?
    persist!(profile, gtag)
  end

  private

  def simple?
    Event.find(event_id).get_parameter("gtag", "form", "format") == "simple"
  end

  def persist!(profile, gtag)
    profile.save
    @gtag_assignation = profile.gtag_assignment.create(credentiable: gtag)
    GtagMailer.assigned_email(@gtag_assignation).deliver_later
  end
end
