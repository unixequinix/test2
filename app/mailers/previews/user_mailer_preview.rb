class UserMailerPreview < ActionMailer::Preview
  def invite_to_event
    event = Event.with_state("launched").first || FactoryGirl.build(:event)
    registration = EventRegistration.first || EventRegistration.new(event: event)
    UserMailer.invite_to_event(registration)
  end

  def reset_password_instructions
    UserMailer.reset_password_instructions(User.first, "faketoken", {})
  end
end
