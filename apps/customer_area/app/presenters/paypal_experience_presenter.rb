class PaypalExperiencePresenter < BasePresenter
  def can_render?
    @event.launched? || @event.started?
  end

  def path
    "events/events/paypal_experience"
  end
end
