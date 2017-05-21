class UserMailer < ApplicationMailer
  def invite_to_event(registration)
    @registration = registration
    @event = @registration.event

    headers["X-No-Spam"] = "True"
    mail(to: registration.email, reply_to: @event.support_email, subject: "You have been invited to join #{@event.name} list of operators")
  end
end
