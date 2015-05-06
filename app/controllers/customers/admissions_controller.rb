class Customers::AdmissionsController < Customers::BaseController

  def new
    @admission = Admission.new
  end

  def create
    ticket = Ticket.find_by(number: params[:ticket_number])
    if !ticket.nil?
      @admission = Admission.new(customer_id: current_customer.id, ticket_id: ticket.id)
      if @admission.save
        @credit_log = CreditLog.create(customer_id: current_customer.id, transaction_type: CreditLog::TICKET_ASSIGMENT, amount: ticket.ticket_type.credit)
        flash[:notice] = "created TODO"
        redirect_to customer_root_url
      else
        flash[:error] = @admission.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = "This is not a valid ticket TODO"
      render :new
    end
  end

  def destroy
    @admission = Admission.find(params[:id])
    @admission.unassign!
    @credit_log = CreditLog.create(customer_id: current_customer.id, transaction_type: CreditLog::TICKET_ASSIGMENT, amount: -@admission.ticket.ticket_type.credit)
    flash[:notice] = "unassigned TODO"
    redirect_to customer_root_url
  end

end
