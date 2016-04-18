class GtagAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :tag_uid, String
  attribute :tag_serial_number, String
  attribute :event_id, Integer

  validates_presence_of :tag_uid
  validates_presence_of :tag_serial_number, unless: :simple?

  def save(fetcher, current_customer)
    number = tag_serial_number.to_s.strip.upcase
    gtag = fetcher.find_by(tag_uid: tag_uid.strip.upcase, tag_serial_number: number)

    add_error("alerts.gtag.invalid") && return unless gtag
    credentiable = Profile::Checker.for_credentiable(gtag, current_customer)
    add_error("alerts.gtag.already_assigned") && return unless credentiable

    GtagMailer.assigned_email(credentiable).deliver_later
  end

  private

  def add_error(str)
    errors.add(:gtag_assignment, I18n.t(str))
  end

  def simple?
    Event.find(event_id).get_parameter("gtag", "form", "format") == "simple"
  end
end
