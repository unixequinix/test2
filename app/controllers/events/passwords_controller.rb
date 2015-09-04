class Events::PasswordsController < Events::DeviseBaseController
  skip_before_action :authenticate_customer!, only: [:new, :create, :edit, :update]

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.send_reset_password_instructions(permitted_params)
    if successfully_sent?(@customer)
      redirect_to after_sending_reset_password_instructions_path_for(@customer.class.name)
    else
      render :new
    end
  end

  def edit
    @customer = Customer.new
    set_minimum_password_length
    @customer.reset_password_token = params[:reset_password_token]
  end

  def update
    @customer = Customer.reset_password_by_token(permitted_params)
    if @customer.errors.empty?
      flash_message = @customer.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      sign_in(@customer.class.name, @customer)
      redirect_to after_resetting_password_path_for(@customer)
    else
      render :edit
    end
  end

  private

  def permitted_params
    params.require(:customer)
      .permit(:email, :password, :password_confirmation, :reset_password_token)
      .merge(event_id: current_event.id)
  end


  def after_resetting_password_path_for(resource)
    new_event_session_path(current_event)
  end

  def after_sending_reset_password_instructions_path_for(resource_name)
    new_event_session_path(current_event, password_sent: true)
  end
end