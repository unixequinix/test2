class GtagMailerPreview < ActionMailer::Preview
  def assigned_email
    GtagMailer.assigned_email(CustomerEventProfile.first.active_gtag_assignment)
  end

  def unassigned_email
    GtagMailer.unassigned_email(CustomerEventProfile.first.active_gtag_assignment)
  end
end
