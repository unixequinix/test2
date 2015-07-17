class Admins::AdmissionsController < Admins::BaseController

  def new
    @admission = Admission.new
    @customer = Customer.with_deleted.find(params[:customer_id])
  end

  def create
    ticket = Ticket.find_by(number: params[:ticket_number])
    @customer = Customer.with_deleted.find(params[:customer_id])
    if !ticket.nil?
      @admission = Admission.new(customer_id: @customer.id, ticket_id: ticket.id)
      if @admission.save
        @credit_log = CreditLog.create(customer_id: params[:customer_id], transaction_type: CreditLog::TICKET_ASSIGNMENT, amount: ticket.ticket_type.credit) unless ticket.ticket_type.credit.nil?
        flash[:notice] = I18n.t('alerts.created')
        redirect_to admins_customer_url(@customer)
      else
        flash[:error] = @admission.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = I18n.t('alerts.admissions', companies: TicketType.companies.join(', '))
      render :new
    end
  end

  def destroy
    @admission = Admission.find(params[:id])
    @customer = @admission.customer
    @admission.unassign!
    @credit_log = CreditLog.create(customer_id: @customer.id, transaction_type: CreditLog::TICKET_UNASSIGNMENT, amount: -@admission.ticket.ticket_type.credit) unless @admission.ticket.ticket_type.credit.nil?
    flash[:notice] = I18n.t('alerts.unassigned')
    redirect_to admins_customer_url(@customer)
  end
end
