class ClaimsPresenter < BasePresenter
  def can_render?
    @event.refunds?
  end

  def path
    @gtag_assignment.present? ? "claims" : "claims_none"
  end

  def refunds_title
    completed_claim? ? I18n.t("dashboard.refunds.title") : I18n.t("dashboard.without_refunds.title")
  end

  def refund_services
    @event.selected_refund_services
  end

  def refund_disclaimer
    @event.refund_disclaimer
  end

  def action_name(refund_service)
    @event.get_parameter("refund", refund_service, "action_name")
  end

  def refundable?(refund_service)
    @gtag_assignment.credentiable.refundable?(refund_service)
  end

  def any_refundable_method?
    @gtag_assignment.credentiable.any_refundable_method?
  end

  def gtag_credit_amount
    "#{@gtag_assignment.credentiable.refundable_amount} #{@event.currency}"
  end

  def refund_status
    if any_refundable_method?
      completed_claim? ? "refunds" : "without_refunds"
    else
      "not_refundable"
    end
  end

  def call_to_action
    I18n.t("dashboard.#{refund_status}.call_to_action")
  end

  def refund_snippets
    refund_services.each do |refund_service|
      method("snippet_#{refund_status}").call(refund_service)
    end
    nil
  end

  def snippet_without_refunds
  end

  def snippet_refunds(refund_service)
    context.link_to(action_name(refund_service),
                            context.send("new_event_#{refund_service}_claim_path", @event),
                            class: "btn btn-refund-method")
  end

  def snippet_not_refundable(refund_service)
    context.content_tag("a", action_name(refund_service),
                                class: "btn btn-refund-method btn-blocked",
                                disabled: !refundable?(refund_service))
  end

end
