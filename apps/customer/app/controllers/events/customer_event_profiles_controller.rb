class Events::CustomerEventProfilesController < Events::BaseController
  def new
    @customer_event_profile_form =
      CustomerEventProfileForm.new(customer_event_profile: CustomerEventProfile.new, customer: Customer.new)
  end

  def create
    @customer_event_profile_form =
      CustomerEventProfileForm.new(customer_event_profile: CustomerEventProfile.new, customer: Customer.new)
    if @customer_event_profile_form.validate(permitted_params) && @customer_event_profile_form.save
      customer = @customer_event_profile_form.customer
      sign_in(customer)
      redirect_to after_sign_in_path_for(customer), notice:'ALLES GUT!! TODO'
    else
      puts @customer_event_profile_form.errors.inspect
      render :new, error: 'ERROR Creating admission TODO'
    end
  end

  private

  def permitted_params
    params.require(:customer_event_profile)
      .permit(:email, :name, :surname, :password, :password_confirmation,
              :agreed_on_registration).merge(event_id: current_event.id)
  end
end
