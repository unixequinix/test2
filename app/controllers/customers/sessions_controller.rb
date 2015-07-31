class Customers::SessionsController < Devise::SessionsController

  def new
    @sign_up = params[:sign_up]
    @confirmed = params[:confirmed]
    @password_sent = params[:password_sent]
    super
  end
end
