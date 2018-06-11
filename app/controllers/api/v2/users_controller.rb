module Api::V2
  class UsersController < ActionController::API
    # POST /users/can_login
    def can_login
      user = User.authenticate(user_params[:login], user_params[:password])
      render status: user ? :ok : :unauthorized
    end

    private

    def user_params
      params.require(:user).permit(:login, :password)
    end
  end
end
