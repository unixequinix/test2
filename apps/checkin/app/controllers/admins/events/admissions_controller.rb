class Admins::Events::AdmissionsController < Admins::Events::CheckingBaseController

  def new
    @admission = Admission.new
    @customer_event_profile = CustomerEventProfile.with_deleted.find(params[:customer_event_profile_id])
  end

  def create
    ticket = Ticket.find_by(number: params[:ticket_number].strip, event: current_event)
    @customer_event_profile = CustomerEventProfile.with_deleted.find(params[:customer_event_profile_id])
    if !ticket.nil?
      @admission = Admission.new(customer_event_profile_id: @customer_event_profile.id, ticket_id: ticket.id)
      if @admission.save
        @credit_log = CreditLog.create(customer_event_profile_id: params[:customer_event_profile_id], transaction_type: CreditLog::TICKET_ASSIGNMENT, amount: ticket.ticket_type.credit) unless ticket.ticket_type.credit.nil?
        flash[:notice] = I18n.t('alerts.created')
        redirect_to admins_event_customer_event_profile_url(current_event, @customer_event_profile)
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
    @customer_event_profile = @admission.customer_event_profile
    @admission.unassign!
    @credit_log = CreditLog.create(customer_event_profile_id: @customer_event_profile.id, transaction_type: CreditLog::TICKET_UNASSIGNMENT, amount: -@admission.ticket.ticket_type.credit) unless @admission.ticket.ticket_type.credit.nil?
    flash[:notice] = I18n.t('alerts.unassigned')
    redirect_to admins_event_customer_event_profile_url(current_event, @customer_event_profile)
  end
end
