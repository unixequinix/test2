class Events::AdmissionsController < Events::BaseController
  def new
    @admission_form =
      AdmissionForm.new(admission: Admission.new, customer: Customer.new)
  end

  def create
    @admission_form =
      AdmissionForm.new(admission: Admission.new, customer: Customer.new)
    if @admission_form.validate(permitted_params) && @admission_form.save
      flash[:notice] = 'ALLES GUT!! TODO'
      # TODO: where to redirect?
      customer = @admission_form.model[:customer]
      sign_in(customer)
      redirect_to :root
    else
      render :new
    end
  end

  private

  def permitted_params
    params.require(:admission).permit(:email, :name, :surname,
      :password, :password_confirmation, :agreed_on_registration, :event_id)
  end
end