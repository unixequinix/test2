class Events::AdmissionsController < Events::BaseController
  def new
    @admission_form =
      AdmissionForm.new(customer: Customer.new, admission: Admission.new)
  end

  def create
  end
end