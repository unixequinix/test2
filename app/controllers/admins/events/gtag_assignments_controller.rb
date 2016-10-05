class Admins::Events::GtagAssignmentsController < Admins::Events::BaseController
  def new
    @customer = current_event.customers.find(params[:customer_id])
    @gtag_assignment_form = GtagAssignmentForm.new
  end

  def create
    @gtag_assignment_form = GtagAssignmentForm.new(gtag_assignment_parameters)
    @customer = current_event.customers.find(params[:customer_id])

    if @gtag_assignment_form.save(current_event.gtags, current_customer)
      redirect_to admins_event_customer_url(current_event, @customer), notice: I18n.t("alerts.created")
    else
      flash[:error] = @gtag_assignment_form.errors.full_messages.join
      render :new
    end
  end

  def destroy
    @credential_assignment = CredentialAssignment.find(params[:id])
    @credential_assignment.unassign!
    @credential_assignment.credentiable

    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to :back
  end

  private

  def gtag_assignment_parameters
    params.require(:gtag_assignment_form).permit(:number, :tag_uid).merge(event_id: current_event.id)
  end

  def current_customer
    current_event.customers.find(params[:customer_id])
  end

  def current_profile
    current_customer.profile || Profile.create(customer: current_customer, event: current_event)
  end
end
