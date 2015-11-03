class Events::RegistrationsController < Events::BaseController
  layout 'event'
  skip_before_filter :authenticate_customer!

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(permitted_params)
    if @customer.save
      CustomerMailer.confirmation_instructions_email(@customer).deliver_later
      @customer.update(confirmation_sent_at: Time.now.utc)
      flash[:notice] = t("registrations.customer.success")
      redirect_to after_inactive_sign_up_path
    else
      @customer.password =  nil
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

  def after_inactive_sign_up_path
    event_login_path(current_event, sign_up: true)
  end

  def permitted_params
    params.require(:customer).permit(:email, :password, :password_confirmation,
      :current_password, :name, :surname, :phone, :address, :city, :country,
      :postcode, :gender, :birthdate, :event_id, :agreed_on_registration)
  end
end
