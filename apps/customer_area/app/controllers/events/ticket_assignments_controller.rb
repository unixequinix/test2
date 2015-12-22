class Events::TicketAssignmentsController < Events::BaseController
  def new
    @ticket_assignment_form = TicketAssignmentForm.new
  end
  def create
    ticket = Ticket.find_by(number: params[:ticket_assignment_form][:number].strip, event: current_event)

    if !ticket.nil?
      @credential_assignment_ticket = current_customer_event_profile.credential_assignments.build(credentiable: ticket)
      if @credential_assignment_ticket.save
        @credit_log = CreditLog.create(
          customer_event_profile_id: current_customer_event_profile.id,
          transaction_type: CreditLog::TICKET_ASSIGNMENT,
          amount: ticket.ticket_type.credit) if ticket.ticket_type.credit.present?
        flash[:notice] = I18n.t("alerts.created")
        redirect_to event_url(current_event)
      else
        flash[:error] = @credential_assignment_ticket.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = I18n.t("alerts.admissions", companies: TicketType.companies(current_event).join(", "))
      render :new
    end
  end

  def destroy
    @ticket_assignment = CredentialAssignment.find(params[:id])
    @ticket_assignment.unassign!
    @credit_log = CreditLog.create(customer_event_profile_id: current_customer_event_profile.id, transaction_type: CreditLog::TICKET_UNASSIGNMENT, amount: -@ticket_assignment.credentiable.ticket_type.credit) unless @ticket_assignment.credentiable.ticket_type.credit.nil?
    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to event_url(current_event)
  end
end
