module Api::V2
  class UsersController < ActionController::API
    # POST /users/can_login
    def can_login
      user = User.authenticate(user_params[:login], user_params[:password])

      if user
        render json: user
      else
        render status: :unauthorized
      end
    end

    private

    def user_params
      params.require(:user).permit(:login, :password)
    end
  end
end
