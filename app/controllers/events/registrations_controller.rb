class Events::RegistrationsController < Events::DeviseBaseController
  skip_before_action :authenticate_customer!, only: [:new, :create]

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(permitted_params)
    @customer.skip_confirmation_notification!
    if @customer.save
      if @customer.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        create_customer_event_profile(@customer)
        sign_up(@customer.class.name, @customer)
        redirect_to after_sign_up_path_for(@customer)
      else
        Customer.send_confirmation_instructions(permitted_params.merge(event_id: current_event.id))
        set_flash_message :notice, :"signed_up_but_#{@customer.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        create_customer_event_profile(@customer)
        redirect_to after_inactive_sign_up_path_for(@customer)
      end
    else
      clean_up_passwords @customer
      set_minimum_password_length
      render :new
    end
  end

  def edit
    @customer = current_customer
  end

  def update
    @customer = current_customer
    prev_unconfirmed_email = @customer.unconfirmed_email if @customer.respond_to?(:unconfirmed_email)
    if @customer.update(permitted_params)
      if is_flashing_format?
        flash_key = update_needs_confirmation?(@customer, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in(@customer.class.name, @customer)
      redirect_to after_update_path_for(@customer)
    else
      clean_up_passwords @customer
      render :edit
    end
  end

  private

  def permitted_params
    params.require(:customer)
      .permit(:email, :name, :surname, :password, :password_confirmation,
              :agreed_on_registration)
  end

  def after_inactive_sign_up_path_for(resource)
    new_event_session_path(current_event, sign_up: true)
  end

  def after_update_path_for(resource)
    new_event_session_path(current_event)
  end
end
