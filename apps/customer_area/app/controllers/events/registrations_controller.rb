class Events::RegistrationsController < Events::BaseController
  layout "event"
  skip_before_filter :authenticate_customer!, only: [:new, :create]

  def new
    @new_profile_form = NewProfileForm.new(Customer.new)
  end

  def create
    @new_profile_form = NewProfileForm.new(Customer.new)
    if @new_profile_form.validate(permitted_params) && @new_profile_form.save
      CustomerMailer.confirmation_instructions_email(@new_profile_form.model).deliver_later
      @new_profile_form.model.update(confirmation_sent_at: Time.now.utc)
      flash[:notice] = t("registrations.customer.success")
      redirect_to after_inactive_sign_up_path
    else
      @new_profile_form.password =  nil
      render :new
    end
  end

  def edit
    @edit_profile_form = EditProfileForm.new(current_customer)
  end

  def update
    @edit_profile_form = EditProfileForm.new(current_customer)
    if @edit_profile_form.validate(permitted_params) && @edit_profile_form.save
      redirect_to after_update_path
    else
      render :edit
    end
  end

  private

  def after_update_path
    customer_root_path(current_event)
  end

  def after_inactive_sign_up_path
    event_login_path(current_event, sign_up: true)
  end

  def permitted_params
    params.require(:customer).permit(:event_id, :email, :name,
                                     :surname, :phone, :address, :city, :country, :postcode,
                                     :gender, :birthdate, :password, :current_password,
                                     :agreed_on_registration, :agreed_event_condition)
  end
end
