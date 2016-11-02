class GtagMailerPreview < ActionMailer::Preview
  def assigned_email
    GtagMailer.assigned_email(Profile.first.active_gtag)
  end

  def unassigned_email
    GtagMailer.unassigned_email(Profile.first.active_gtag)
  end
end
