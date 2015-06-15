module ControllerMacros
  def login_customer
    @request.env['devise.mapping'] = Devise.mappings[:customers]
    sign_in create(:customer)
  end

  def login_admin
    @request.env['devise.mapping'] = Devise.mappings[:admins]
    sign_in create(:admin)
  end
end
