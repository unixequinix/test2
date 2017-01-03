class WelcomePresenter < BasePresenter
  def can_render?
    !(@event.created? || @event.closed?) && !@customer.active_credentials?
  end

  def path
    "events/events/welcome"
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def render_credentiable_links
    gtag_btn = generate_button("gtag")
    ticket_btn = generate_button("ticket")
    sep = context.content_tag(:span, I18n.t("registration.new.or"), class: "buttons-separator")

    output = ""
    output << ticket_btn if @event.ticket_assignation? && !@event.finished?
    output << sep if @event.gtag_assignation? && (@event.ticket_assignation? && !@event.finished?)
    output << gtag_btn if @event.gtag_assignation?
    output
  end

  def render_description
    return if @event.gtag_assignation? || @event.ticket_assignation?
    I18n.t("sessions.first_register.description_without_credentiable")
  end

  def generate_button(button)
    css = "btn btn-action btn-action-first-registration"
    css += " btn-action-secondary" if @event.gtag_assignation? && (@event.ticket_assignation? && !@event.finished?)
    path = context.send("new_event_#{button}_assignment_path", @event)
    context.link_to(I18n.t("dashboard.first_register.#{button}"), path, class: css + " cb-add_#{button}")
  end
end
