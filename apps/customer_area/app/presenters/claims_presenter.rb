class ClaimsPresenter < BasePresenter
  def can_render?
    @event.refunds?
  end

  def path
    @gtag_registration.present? ? 'claims' :
                                  'claims_none'
  end

  def refunds_title
    completed_claim? ? I18n.t('dashboard.refunds.title') :
                      I18n.t('dashboard.without_refunds.title')
  end

  def refund_services
    @event.selected_refund_services
  end

  def refund_disclaimer
    @event.refund_disclaimer
  end

  def action_name(refund_service)
    @event.get_parameter('refund', refund_service, 'action_name')
  end

  def refundable?
    # @gtag_registration.gtag.refundable?
    true
  end

  def gtag_credit_amount
    "#{@gtag_registration.gtag.refundable_amount} #{I18n.t('currency_symbol')}"
  end

  def call_to_action
    if refundable?
      completed_claim? ? I18n.t('dashboard.refunds.call_to_action') : I18n.t('dashboard.without_refunds.call_to_action')
    else
      I18n.t('dashboard.not_refundable.call_to_action', fee: @event.refund_fee, minimum: @event.refund_minimun, currency_symbol: I18n.t('currency_symbol'))
    end
  end
end
