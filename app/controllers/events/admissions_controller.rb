class Events::AdmissionsController < Events::BaseController
  def new
    @admission_form =
      AdmissionForm.new(admission: Admission.new, customer: Customer.new)
  end

  def create
    @admission_form =
      AdmissionForm.new(admission: Admission.new, customer: Customer.new)
    if @admission_form.validate(permitted_params) && @admission_form.save
      customer = @admission_form.customer
      sign_in(customer)
      redirect_to after_sign_in_path_for(customer), notice:'ALLES GUT!! TODO'
    else
      puts @admission_form.errors.inspect
      render :new, error: 'ERROR Creating admission TODO'
    end
  end

  private

  def permitted_params
    params.require(:admission)
      .permit(:email, :name, :surname, :password, :password_confirmation,
              :agreed_on_registration).merge(event_id: current_event.id)
  end
end
