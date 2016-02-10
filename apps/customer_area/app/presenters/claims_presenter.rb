class ClaimsPresenter < BasePresenter
  def can_render?
    @event.refunds?
  end

  def path
    @gtag_registration.present? ? "claims" :
                                  "claims_none"
  end

  def refunds_title
    completed_claim? ? I18n.t("dashboard.refunds.title") :
                      I18n.t("dashboard.without_refunds.title")
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
    @gtag_registration.gtag.refundable?(refund_service)
  end

  def any_refundable_method?
    @gtag_registration.gtag.any_refundable_method?
  end

  def gtag_credit_amount
    "#{@gtag_registration.gtag.refundable_amount} #{@event.currency}"
  end

  def call_to_action
    if any_refundable_method?
      I18n.t("dashboard.refunds.call_to_action") && return if completed_claim?
      I18n.t("dashboard.without_refunds.call_to_action")
    else
      I18n.t("dashboard.not_refundable.call_to_action")
    end
  end

  def refund_actions
    actions = ""
    return "" unless any_refundable_method? && !completed_claim?

    refund_services.each do |refund_service|
      class_definition = "btn btn-refund-method"

      if !refundable?(refund_service)
        class_definition << " btn-blocked"
        actions << context.content_tag("a", action_name(refund_service),
                                       class: class_definition, disabled: not_refundable)
      else
        actions << context.link_to(action_name(refund_service),
                                   context.send("new_event_#{refund_service}_claim_path", @event),
                                   class: class_definition)
      end
    end
    actions
  end
end
