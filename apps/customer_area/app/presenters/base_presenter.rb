class BasePresenter
  include ActionView::Helpers::NumberHelper
  attr_accessor :context, :profile, :gtag_assignment, :refund, :event,
                :ticket_assignments, :purchases

  def initialize(dashboard, context)
    @context = context
    @profile = dashboard.profile
    @event = dashboard.event
    @ticket_assignments = dashboard.ticket_assignments
    @completed_claim = dashboard.completed_claim
    @gtag_assignment = dashboard.gtag_assignment
    @purchases = dashboard.purchases
  end

  def event_url
    @event.url
  end

  def completed_claim?
    @completed_claim.present?
  end

  def credential_present?
    @ticket_assignments.present? || @gtag_assignment.present?
  end

  delegate :tag_uid, to: :gtag, prefix: true

  def gtag_refundable_amount
    gtag_assignment.refundable_amount
  end

  private

  def gtag
    @gtag_assignment ? @gtag_assignment.credentiable : Gtag.new
  end

  def formatted_date
    Time.zone.now.strftime("%Y-%m-%d")
  end
end
