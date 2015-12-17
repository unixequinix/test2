class Admins::Events::AdmissionsController < Admins::Events::CheckinBaseController
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
        @credit_log = CreditLog.create(customer_event_profile: current_customer_event_profile, transaction_type: CreditLog::TICKET_ASSIGNMENT, amount: ticket.ticket_type.credit) unless ticket.ticket_type.credit.nil?
        flash[:notice] = I18n.t("alerts.created")
        redirect_to admins_event_customer_url(current_event, @customer)
      else
        flash[:error] = @admission.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = I18n.t("alerts.admissions", companies: TicketType.companies(current_event).join(", "))
      render :new
    end
  end

  def destroy
    @admission = Admission.find(params[:id])
    @customer_event_profile = @admission.customer_event_profile
    @admission.unassign!
    @credit_log = CreditLog.create(customer_event_profile: @customer_event_profile, transaction_type: CreditLog::TICKET_UNASSIGNMENT, amount: -@admission.ticket.ticket_type.credit) unless @admission.ticket.ticket_type.credit.nil?
    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to admins_event_customer_url(current_event, @customer_event_profile.customer)
  end

  private

  def current_customer_event_profile
    current_customer.customer_event_profile ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end

  def current_customer
    Customer.find(params[:customer_id])
  end
end
