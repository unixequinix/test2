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

  def refund_service
    @event.refund_service
  end

  def refundable?
    @gtag_registration.refundable?
  end

  def gtag_credit_amount
    "#{@gtag_registration.refundable_amount} EUR"
  end

  def call_to_action
    if refundable?
      completed_claim? ? I18n.t('dashboard.refunds.call_to_action') : I18n.t('dashboard.without_refunds.call_to_action')
    else
      I18n.t('dashboard.not_refundable.call_to_action', fee: @event.get_parameter('refund', @event.refund_service, 'fee'), minimum: @event.get_parameter('refund', @event.refund_service, 'minimum'))
    end
  end
end
