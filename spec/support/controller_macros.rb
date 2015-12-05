module ControllerMacros
  def login_customer
    login_as(:customer)
  end

  def login_admin
    login_as(:admin)
  end
end
