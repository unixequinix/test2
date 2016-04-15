class WelcomePresenter < BasePresenter
  def can_render?
    @event.launched? &&
      !@customer_event_profile.active_credentials? &&
      (@event.gtag_assignation? ||
       @event.ticket_assignation?)
  end

  def path
    "events/events/welcome"
  end

  def render_credentiable_links
    css = "btn btn-action btn-action-secondary btn-action-first-registration"
    ticket_btn = context.link_to(I18n.t("dashboard.first_register.ticket"),
                                 context.send("new_event_ticket_assignment_path", @event),
                                 class: css)
    gtag_btn = context.link_to(I18n.t("dashboard.first_register.wristband"),
                               context.send("new_event_gtag_assignment_path", @event),
                               class: css)
    sep = context.content_tag(:span, I18n.t("registration.new.or"), class: "buttons-separator")

    output = ""
    output += ticket_btn if @event.ticket_assignation?
    output += sep if @event.gtag_assignation? && @event.ticket_assignation?
    output += gtag_btn if @event.gtag_assignation?

    ActiveSupport::SafeBuffer.new(output)
  end
end
