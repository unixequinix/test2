class WelcomePresenter < BasePresenter
  def can_render?
    !(@event.created? || @event.closed?) && !@customer.active_credentials?
  end

  def path
    "events/events/welcome"
  end

  def render_credentiable_links
    "#{generate_button('gtag')} #{context.content_tag(:span, I18n.t('registration.new.or'), class: 'buttons-separator')} #{generate_button('ticket')}"
  end

  def generate_button(button)
    css = "btn btn-action btn-action-first-registration"
    css += " btn-action-secondary"
    path = context.send("new_event_#{button}_assignment_path", @event)
    context.link_to(I18n.t("dashboard.first_register.#{button}"), path, class: css + " cb-add_#{button}")
  end
end
