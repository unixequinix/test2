class GtagMailerPreview < ActionMailer::Preview
  def assigned_email
    GtagMailer.assigned_email(Customer.first.active_gtag)
  end

  def unassigned_email
    GtagMailer.unassigned_email(Customer.first.active_gtag)
  end
end
