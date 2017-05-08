class CustomerMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    CustomerMailer.reset_password_instructions(Customer.first, "faketoken", {})
  end

  def welcome
    CustomerMailer.welcome(Customer.first)
  end
end
