class UserMailerPreview < ActionMailer::Preview
  def invite_to_event
    event = Event.with_state("launched").first || FactoryBot.build(:event)
    invitation = EventInvitation.first || EventInvitation.new(event: event)
    UserMailer.invite_to_event(invitation)
  end

  def reset_password_instructions
    UserMailer.reset_password_instructions(User.first, "faketoken", {})
  end
end
