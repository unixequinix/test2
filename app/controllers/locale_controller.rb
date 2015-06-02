class LocaleController < ApplicationController

  # Change the locale in the session
  def change
    session[:locale] = params[:id]
    redirect_to :back
  end

end