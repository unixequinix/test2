class GtagAssignmentForm
  include ActiveModel::Model
  include Virtus.model

  attribute :tag_uid, String
  attribute :event_id, Integer

  validates_presence_of :tag_uid

  def save(fetcher, current_customer)
    uid = tag_uid.strip.upcase
    gtag = fetcher.find_by(tag_uid: uid)

    add_error("alerts.gtag.invalid") && return unless gtag

    begin
      Profile::Checker.for_credentiable(gtag, current_customer)
    rescue RuntimeError
      add_error("alerts.gtag.already_assigned") && return
    end
  end

  private

  def add_error(str)
    errors.add(:gtag_assignment, I18n.t(str))
  end
end
