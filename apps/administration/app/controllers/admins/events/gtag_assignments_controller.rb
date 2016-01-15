class Admins::Events::GtagAssignmentsController < Admins::Events::CheckinBaseController
  def new
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])
    @gtag_assignment_form = GtagAssignmentForm.new
  end

  def create
    @gtag_assignment_form = GtagAssignmentForm.new(gtag_assignment_parameters)
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])

    if @gtag_assignment_form.save(@fetcher.gtags, current_customer_event_profile)
      flash[:notice] = I18n.t('alerts.created')
      redirect_to admins_event_customer_url(current_event, @customer)
    else
      flash[:error] = @gtag_assignment_form.errors.full_messages.join
      render :new
    end
  end

  def destroy
    @credential_assignment = CredentialAssignment.find(params[:id])
    customer_event_profile = @credential_assignment.customer_event_profile
    @credential_assignment.unassign!
    @credential_assignment.credentiable

    flash[:notice] = I18n.t('alerts.unassigned')
    GtagMailer.unassigned_email(@credential_assignment).deliver_later

    redirect_to admins_event_customer_url(current_event, customer_event_profile.customer)
  end

  private

  def gtag_assignment_parameters
    params.require(:gtag_assignment_form).permit(:number, :tag_uid, :tag_serial_number)
  end

  def current_customer
    @fetcher.customers.find(params[:customer_id])
  end

  def current_customer_event_profile
    current_customer.customer_event_profile ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end
end
