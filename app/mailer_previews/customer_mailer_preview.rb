class CustomerMailerPreview < ActionMailer::Preview
  def reset_password_instructions_email
    CustomerMailer.reset_password_instructions_email(Profile.first.customer)
  end
end
