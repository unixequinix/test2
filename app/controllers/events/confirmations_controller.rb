class Events::ConfirmationsController < Events::DeviseBaseController
  skip_before_action :authenticate_customer!, only: [:new, :create, :show]

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.send_confirmation_instructions(permitted_params)
    if successfully_sent?(@customer)
      redirect_to after_resending_confirmation_instructions_path_for(@customer.class.name)
    else
      render :new
    end
  end

  def show
    @customer = Customer.confirm_by_token(params[:confirmation_token])

    if @customer.errors.empty?
      set_flash_message(:notice, :confirmed) if is_flashing_format?
      redirect_to after_confirmation_path_for(@customer.class.name, @customer)
    else
      render :new
    end
  end

  private

  def successfully_sent?(resource)
    notice = if Devise.paranoid
      resource.errors.clear
      :send_paranoid_instructions
    elsif resource.errors.empty?
      :send_instructions
    end

    if notice
      set_flash_message :notice, notice if is_flashing_format?
      true
    end
  end

  def permitted_params
    params.require(:customer)
      .permit(:email, :password, :password_confirmation, :confirmation_token)
      .merge(event_id: current_event.id)
  end

  def after_resending_confirmation_instructions_path_for(resource_name)
    new_event_session_path(current_event, confirmed: true)
  end

  def after_confirmation_path_for(resource_name, resource)
    new_event_session_path(current_event, confirmed: true)
  end

end