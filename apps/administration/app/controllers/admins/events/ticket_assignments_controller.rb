class Admins::Events::TicketAssignmentsController < Admins::Events::CredentialAssignmentsController

  def new
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])
    @ticket_assignment_form = TicketAssignmentForm.new
  end

  def create
    @ticket_assignment_form = TicketAssignmentForm.new(ticket_assignment_parameters)
    @customer = current_customer
    ticket = @fetcher.tickets.find_by(number: @ticket_assignment_form.number.strip)
    ticket_assignment = current_customer_event_profile.credential_assignments.build(credentiable: ticket)
    if ticket_assignment.save
      @credit_log = CreditLog.create(
        customer_event_profile: current_customer_event_profile,
        transaction_type: CreditLog::TICKET_ASSIGNMENT,
        amount: ticket.ticket_type.credit
      ) if ticket.ticket_type.credit.present?
      flash[:notice] = I18n.t('alerts.created')
      redirect_to admins_event_customer_url(current_event, @customer)
    else
      flash[:error] = ticket_assignment.errors.full_messages.join(". ")
      render :new
    end
  end

  def destroy
    credential_assignment = CredentialAssignment.find(params[:id])
    customer_event_profile = credential_assignment.customer_event_profile
    credential_assignment.unassign!
    ticket = credential_assignment.credentiable

    credit_log = CreditLog.create(
      customer_event_profile: customer_event_profile,
      transaction_type: CreditLog::TICKET_UNASSIGNMENT,
      amount: -ticket.ticket_type.credit
    ) if ticket.ticket_type.credit.present?

    flash[:notice] = I18n.t('alerts.unassigned')
    redirect_to admins_event_customer_url(current_event, customer_event_profile.customer)
  end

  private

  def ticket_assignment_parameters
    params.require(:ticket_assignment_form).permit(:number)
  end

end

=begin
  def new
    @admission = Admission.new
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])
  end

  def create
    ticket = Ticket.find_by(number: params[:ticket_number].strip, event: current_event)
    @customer = current_customer
    if !ticket.nil?
      @admission = current_customer_event_profile.admissions.build(ticket: ticket)
      if @admission.save
        @credit_log = CreditLog.create(customer_event_profile_id: params[:customer_event_profile_id], transaction_type: CreditLog::TICKET_ASSIGNMENT, amount: ticket.ticket_type.credit) unless ticket.ticket_type.credit.nil?
        flash[:notice] = I18n.t('alerts.created')
        redirect_to admins_event_customer_url(current_event, @customer)
      else
        flash[:error] = @admission.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = I18n.t('alerts.admissions', companies: TicketType.companies(current_event).join(', '))
      render :new
    end
  end

  def destroy
    @admission = Admission.find(params[:id])
    @customer_event_profile = @admission.customer_event_profile
    @admission.unassign!
    @credit_log = CreditLog.create(customer_event_profile_id: @customer_event_profile.customer.id, transaction_type: CreditLog::TICKET_UNASSIGNMENT, amount: -@admission.ticket.ticket_type.credit) unless @admission.ticket.ticket_type.credit.nil?
    flash[:notice] = I18n.t('alerts.unassigned')
    redirect_to admins_event_customer_url(current_event, @customer_event_profile.customer)
  end


=end