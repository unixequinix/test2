class GtagAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :tag_uid, String
  attribute :tag_serial_number, String
  attribute :event_id, Integer

  validates_presence_of :tag_uid
  validates_presence_of :tag_serial_number, unless: :simple?

  # TODO: to avoid parameter filetring, tag_serial_number should never be included in params
  # =>    and hence in the form in the first place, simple delete DOM element
  def save(fetcher, current_customer)
    serial = tag_serial_number.to_s.strip.upcase
    uid = tag_uid.strip.upcase
    atts = { tag_uid: uid, tag_serial_number: serial }.delete_if { |_k, v| v.blank? }
    gtag = fetcher.find_by(atts)

    add_error("alerts.gtag.invalid") && return unless gtag

    begin
      assignment = Profile::Checker.for_credentiable(gtag, current_customer)
    rescue RuntimeError
      add_error("alerts.gtag.already_assigned") && return
    end

    GtagMailer.assigned_email(assignment).deliver_later
  end

  private

  def add_error(str)
    errors.add(:gtag_assignment, I18n.t(str))
  end

  def simple?
    Event.find(event_id).get_parameter("gtag", "form", "format") == "simple"
  end
end
