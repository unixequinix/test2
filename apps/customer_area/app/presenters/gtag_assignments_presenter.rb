class GtagAssignmentsPresenter < BasePresenter
  def can_render?
    @event.gtag_assignation? &&
      @customer_event_profile.active_credentials?
  end

  def path
    @gtag_assignment.present? ? "gtag_assignments" : "new_gtag_assignments"
  end

  def gtag_assignments_enabled?
    @event.gtag_assignation?
  end

  def customer_has_refund?
    @refund.present?
  end

  def gtag_name
    @event.gtag_name
  end
end
