class GtagAssignmentsPresenter < BasePresenter
  def can_render?
    @event.gtag_assignation? && @profile.active_credentials?
  end

  def path
    @gtag_assignment.present? ? "gtag_assignments" : "new_gtag_assignments"
  end

  def customer_has_refund?
    @refund.present?
  end

  def gtag_name
    @event.gtag_name
  end

  def gtag_assignments_enabled?
    @event.gtag_assignation?
  end

  # TODO: Removed the event state validation for audiodrome
  def gtag_assignments_enabled
    return unless @event.gtag_assignation? && valid_event_state?
    snippet_gtag_assignments
  end

  def snippet_gtag_assignments
    context.link_to(context.event_gtag_assignment_path(context.current_event, gtag_assignment),
                    method: :delete, class: "btn btn-action btn-action-secondary") do
      "#{context.t('dashboard.gtag_registration.button')} " \
      "<span class='hint'>#{context.t('dashboard.gtag_registration.hint')}</span>".html_safe
    end
  end

  def valid_event_state?
    !context.current_event.started? && !context.current_event.finished?
  end
end
