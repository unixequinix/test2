class ClaimMailerPreview < ActionMailer::Preview
  def completed_email
    profile = Profile.first
    claim = FactoryGirl.create(:claim,
                               profile: profile,
                               gtag: profile.active_gtag_assignment.credentiable)
    claim.update(completed_at: Time.now)
    ClaimMailer.completed_email(claim, Event.first)
  end

  def notification_email
    ClaimMailer.notification_email(Profile.first, Event.first)
  end
end
