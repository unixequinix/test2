class Customers::SessionsController < Devise::SessionsController

  def new
    @sign_up = params[:sign_up]
    @confirmed = params[:confirmed]
    super
  end
end
