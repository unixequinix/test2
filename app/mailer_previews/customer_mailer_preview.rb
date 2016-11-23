class CustomerMailerPreview < ActionMailer::Preview
  def reset_password_instructions_email
    CustomerMailer.reset_password_instructions_email(Customer.first)
  end
end
