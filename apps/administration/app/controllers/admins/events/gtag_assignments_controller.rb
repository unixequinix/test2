class Admins::Events::GtagAssignmentsController < Admins::Events::CheckinBaseController
  def new
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])
    @gtag_assignment_form = GtagAssignmentForm.new
  end

  def create
    @gtag_assignment_form = GtagAssignmentForm.new(gtag_assignment_parameters)
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])

    if @gtag_assignment_form.save(@fetcher.gtags, current_customer)
      redirect_to admins_event_customer_url(current_event, @customer),
                  notice: I18n.t("alerts.created")
    else
      flash[:error] = @gtag_assignment_form.errors.full_messages.join
      render :new
    end
  end

  def destroy
    @credential_assignment = CredentialAssignment.find(params[:id])
    profile = @credential_assignment.profile
    @credential_assignment.unassign!
    @credential_assignment.credentiable

    flash[:notice] = I18n.t("alerts.unassigned")
    GtagMailer.unassigned_email(@credential_assignment).deliver_later

    redirect_to admins_event_customer_url(current_event, profile.customer)
  end

  private

  def gtag_assignment_parameters
    params.require(:gtag_assignment_form)
      .permit(:number, :tag_uid)
      .merge(event_id: current_event.id)
  end

  def current_customer
    @fetcher.customers.find(params[:customer_id])
  end

  def current_profile
    current_customer.profile ||
      Profile.new(customer: current_customer, event: current_event)
  end
end
