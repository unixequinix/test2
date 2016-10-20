class ClaimsPresenter < BasePresenter
  def can_render?
    @event.refunds? && @gtag.present?
  end

  def path
    return "credentiable_refund_disabled" unless credentiable_can_refund?(@gtag)
    return "no_credits" unless any_refundable_method?
    return "invalid_balance" unless @profile.valid_balance?
    return "direct_claim" if @profile.enough_money? && @event.direct?
    "transfer_claim"
  end

  def credentiable_can_refund?(credentiable)
    loyalty = credentiable.loyalty?
    card_can_refund = credentiable.card? && @event.get_parameter("gtag", "form", "cards_can_refund") == "true"
    wristband = credentiable.wristband? && @event.get_parameter("gtag", "form", "wristbands_can_refund") == "true"
    return true if loyalty || card_can_refund || wristband
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

  def any_refundable_method?
    @event.selected_refund_services.any? { |service| @profile.refundable?(service) }
  end

  # TODO: think before programming 2 methods which are the same.
  def refund_snippets
    each_refundable.join
  end

  # TODO: check logic. Also check why this is the EXACT same as the method above.... Ridiculous
  def each_refundable
    return [] unless any_refundable_method?
    refund_services.each do |refund_service|
      refundable = @profile.refundable?(refund_service) ? "refundable" : "not_refundable"
      yield method("snippet_#{refundable}").call(refund_service)
    end
  end

  def snippet_not_refundable(refund_service)
    context.content_tag("a", action_name(refund_service),
                        class: "disabled",
                        disabled: !@profile.refundable?(refund_service))
  end

  # TODO: dont use sends. They are a MAJOR security risk
  def snippet_refundable(refund_service)
    context.link_to(action_name(refund_service),
                    context.send("new_event_#{refund_service}_claim_path", @event),
                    class: "")
  end
end
