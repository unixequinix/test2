class LocaleController < ApplicationController

  # Change the locale in the session
  def change
    session[:locale] = params[:id]
    puts "entra"
    redirect_to :back
  end

end