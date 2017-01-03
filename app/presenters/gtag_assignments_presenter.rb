class GtagAssignmentsPresenter < BasePresenter
  def can_render?
    @event.gtag_assignation? && @customer.active_credentials?
  end

  def path
    @gtag ? "gtag_assignments" : "new_gtag_assignments"
  end

  def customer_has_refund?
    @refund.present?
  end

  def gtag_assignments_enabled?
    @event.gtag_assignation?
  end

  def gtag_assignments_enabled
    return unless @event.gtag_assignation? && valid_event_state?
    snippet_gtag_assignments
  end

  def snippet_gtag_assignments
    text = "#{context.t('dashboard.gtag_registration.button')} <span class='hint'>#{context.t('dashboard.gtag_registration.hint')}</span>"
    path = context.event_gtag_assignment_path(context.current_event, gtag.id)
    context.link_to(text, path, method: :delete, class: "btn btn-action btn-action-secondary")
  end

  def valid_event_state?
    !context.current_event.started? && !context.current_event.finished?
  end
end
