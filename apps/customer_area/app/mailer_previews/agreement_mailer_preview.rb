class AgreementMailerPreview < ActionMailer::Preview
  def accepted_email
    AgreementMailer.accepted_email(Customer.first)
  end
end
