class GtagAssignmentsPresenter < BasePresenter
  def can_render?
    true
  end

  def gtag_tag_uid
    @gtag.tag_uid
  end

  def path
    @gtag ? "gtag_assignments" : "new_gtag_assignments"
  end

  def customer_has_refund?
    @refund.present?
  end

  def gtag_show_remove?
    valid_event_state?
  end

  def valid_event_state?
    !context.current_event.started? && !context.current_event.finished?
  end
end
