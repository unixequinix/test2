class ClaimsPresenter < BasePresenter
  def can_render?
    @event.refunds? && @gtag_assignment.present?
  end

  def path
    claim_method = Management::RefundManager.check(@customer_event_profile, 150)
    return unless @gtag_assignment.present?
    return "no_credits" if @customer_event_profile.refundable_money_amount.zero?
    return "invalid_balance" unless BalanceCalculator.new(@customer_event_profile).valid_balance?
    "#{claim_method}_claim"
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
    actions = ""
    if any_refundable_method? && !completed_claim?
      refund_services.each do |refund_service|
        refundable = refundable?(refund_service) ? "refundable" : "not_refundable"
        actions << method("snippet_#{refundable}").call(refund_service)
      end
    end
    actions
  end

  def snippet_not_refundable(refund_service)
    context.content_tag("a", action_name(refund_service),
                        class: "disabled",
                        disabled: !refundable?(refund_service))
  end

  def snippet_refundable(refund_service)
    context.link_to(action_name(refund_service),
                    context.send("new_event_#{refund_service}_claim_path", @event),
                    class: "")
  end

  # TODO: check logic
  def each_refundable
    return [] unless any_refundable_method? && !completed_claim?
    refund_services.each do |refund_service|
      refundable = refundable?(refund_service) ? "refundable" : "not_refundable"
      yield method("snippet_#{refundable}").call(refund_service)
    end
  end
end
