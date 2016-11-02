class BasePresenter
  include ActionView::Helpers::NumberHelper
  attr_accessor :context, :profile, :gtag, :refund, :event, :tickets, :purchases

  def initialize(dashboard, context)
    @context = context
    @profile = dashboard.profile
    @event = dashboard.event
    @tickets = dashboard.tickets
    @completed_claim = dashboard.completed_claim
    @gtag = dashboard.gtag
    @purchases = dashboard.purchases
  end

  def event_url
    @event.url
  end

  def completed_claim?
    @completed_claim.present?
  end

  def credential_present?
    @tickets.any? || @gtags.any?
  end

  delegate :tag_uid, to: :gtag, prefix: true

  private

  def formatted_date
    Time.zone.now.strftime("%Y-%m-%d")
  end
end
