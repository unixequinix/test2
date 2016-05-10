class ClaimMailerPreview < ActionMailer::Preview
  def completed_email
    event = Event.first
    profile = Profile.first
    gtag = Gtag.create!(event: event, tag_uid: "ERTYUJHB#{rand(10_000)}", credential_redeemed: true)
    CredentialAssignment.create!(profile: profile, credentiable: gtag)
    claim = FactoryGirl.create(:claim,
                               profile: profile,
                               gtag: profile.active_gtag_assignment.credentiable)
    claim.update(completed_at: Time.zone.now)
    ClaimMailer.completed_email(claim, event)
  end

  def notification_email
    ClaimMailer.notification_email(Profile.first, event)
  end
end
