class Events::AdmissionsController < Events::BaseController

  def new
    @admission = Admission.new
  end

  def create
    ticket = Ticket.find_by(number: params[:ticket_number].strip, event: current_event)
    if !ticket.nil?
      @admission = current_customer_event_profile.admissions.build(ticket: ticket)
      if @admission.save
        @credit_log = CreditLog.create(customer_event_profile_id: current_customer_event_profile.id, transaction_type: CreditLog::TICKET_ASSIGNMENT, amount: ticket.ticket_type.credit) unless ticket.ticket_type.credit.nil?
        flash[:notice] = I18n.t('alerts.created')
        redirect_to event_url(current_event)
      else
        flash[:error] = @admission.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = I18n.t('alerts.admissions', companies: TicketType.companies( current_event).join(', '))
      render :new
    end
  end

  def destroy
    @admission = Admission.find(params[:id])
    @admission.unassign!
    @credit_log = CreditLog.create(customer_event_profile_id: current_customer_event_profile.id, transaction_type: CreditLog::TICKET_UNASSIGNMENT, amount: -@admission.ticket.ticket_type.credit) unless @admission.ticket.ticket_type.credit.nil?
    flash[:notice] = I18n.t('alerts.unassigned')
    redirect_to event_url(current_event)
  end

end
