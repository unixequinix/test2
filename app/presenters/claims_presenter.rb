class ClaimsPresenter < BasePresenter
  def can_render?
    @event.refunds?
  end

  def path
    @gtag_registration.present? ? 'claims' :
                                  'claims_none'
  end

  def refunds_title
    refund_present? ? I18n.t('dashboard.refunds.title') :
                      I18n.t('dashboard.without_refunds.title')
  end

  def call_to_action
    if refund_present?
      I18n.t('dashboard.refunds.call_to_action', date: formatted_date)
    else
      I18n.t('dashboard.without_refunds.call_to_action')
    end
  end
end
