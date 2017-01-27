class BasePresenter
  include ActionView::Helpers::NumberHelper
  attr_accessor :context, :customer, :gtag, :refund, :event, :tickets

  def initialize(dashboard, context)
    @context = context
    @customer = dashboard.customer
    @event = dashboard.event
    @tickets = dashboard.tickets
    @gtag = dashboard.gtag
  end

  def credential_present?
    @tickets.any? || @gtags.any?
  end

  delegate :tag_uid, to: :gtag, prefix: true
end
