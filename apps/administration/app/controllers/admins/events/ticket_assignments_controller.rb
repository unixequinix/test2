class Admins::Events::TicketAssignmentsController < Admins::Events::CheckinBaseController
  def new
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])
    @ticket_assignment_form = TicketAssignmentForm.new
  end

  def create
    @ticket_assignment_form = TicketAssignmentForm.new(ticket_assignment_parameters)
    @customer = current_customer
    if @ticket_assignment_form.save(@fetcher.tickets, current_customer_event_profile, current_event)
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_customer_url(current_event, @customer)
    else
      flash.now[:error] = @ticket_assignment_form.errors.full_messages.join
      render :new
    end
  end

  def destroy
    customer_credit_creator = CustomerCreditTicketCreator.new
    credential_assignment = CredentialAssignment.find(params[:id])
    customer_event_profile = credential_assignment.customer_event_profile
    ticket = credential_assignment.credentiable
    @credit_log = customer_credit_creator.unassign(ticket) if ticket.credits.present?
    credential_assignment.unassign!
    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to admins_event_customer_url(current_event, customer_event_profile.customer)
  end

  private

  def ticket_assignment_parameters
    params.require(:ticket_assignment_form).permit(:code)
  end

  def current_customer
    @fetcher.customers.find(params[:customer_id])
  end

  def current_customer_event_profile
    current_customer.customer_event_profile ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end
end
