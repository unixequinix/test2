class ClaimsPresenter < BasePresenter
  def can_render?
    @event.refunds? && @gtag_assignment.present?
  end

  def path # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    profile = @profile
    enough_money = profile.refundable_money_amount <= profile.online_refundable_money_amount
    return "cards_disabled" if @gtag_assignment.credentiable.card? && !cards_can_refund?
    return "claim_present" if profile.completed_claims.present?
    return "no_credits" unless any_refundable_method?
    return "invalid_balance" unless BalanceCalculator.new(profile).valid_balance?
    return "direct_claim" if enough_money && @event.direct?
    "transfer_claim"
  end

  def refund_services
    @event.selected_refund_services.map(&:to_s) & Claim::TRANSFER_REFUND_SERVICES
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

  def refund_snippets
    return "" unless any_refundable_method? && !completed_claim?
    refund_services.map do |refund_service|
      refundable = refundable?(refund_service) ? "refundable" : "not_refundable"
      method("snippet_#{refundable}").call(refund_service)
    end.join
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

  private

  def cards_can_refund?
    @event.get_parameter("gtag", "form", "cards_can_refund") == "true"
  end
end
