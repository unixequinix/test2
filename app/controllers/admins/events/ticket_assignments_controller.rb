class Admins::Events::TicketAssignmentsController < Admins::Events::BaseController
  def new
    @profile = current_event.profiles.find(params[:id])
    @ticket_assignment_form = TicketAssignmentForm.new
  end

  def create
    @ticket_assignment_form = TicketAssignmentForm.new(ticket_assignment_parameters)
    @customer = current_customer
    if @ticket_assignment_form.save(current_event.tickets, current_profile, current_event)
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_customer_url(current_event, @customer)
    else
      flash.now[:error] = @ticket_assignment_form.errors.full_messages.join
      render :new
    end
  end

  def destroy
    credential_assignment = CredentialAssignment.find(params[:id])
    ticket = credential_assignment.credentiable
    @credit_log = CreditWriter.reassign_ticket(ticket, :unassign) if ticket.credits.present?
    credential_assignment.unassign!
    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to :back
  end

  private

  def ticket_assignment_parameters
    params.require(:ticket_assignment_form).permit(:code)
  end
end
