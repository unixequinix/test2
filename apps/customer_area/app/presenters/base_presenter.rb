class BasePresenter
  attr_accessor :context, :customer_event_profile, :gtag_assignment, :refund, :event,
                :ticket_assignments, :purchases

  def initialize(dashboard, context)
    @context = context
    @customer_event_profile = dashboard.customer_event_profile
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

  def ticket_assignments_present?
    @ticket_assignments.any?
  end

  def gtag_tag_uid
    gtag.tag_uid
  end

  def gtag_refundable_amount
    gtag_assignment.refundable_amount
  end

  private

  def gtag
    @gtag_assignment ? @gtag_assignment.credentiable : Gtag.new
  end

  def formatted_date
    Time.now.strftime("%Y-%m-%d")
  end
end
