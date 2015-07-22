class Customers::AdmissionsController < Customers::BaseController
  before_action :check_has_not_admissions!, only: [:new, :create]

  def new
    @admission = Admission.new
  end

  def create
    ticket = Ticket.find_by(number: params[:ticket_number].strip)
    if !ticket.nil?
      @admission = Admission.new(customer_id: current_customer.id, ticket_id: ticket.id)
      if @admission.save
        @credit_log = CreditLog.create(customer_id: current_customer.id, transaction_type: CreditLog::TICKET_ASSIGNMENT, amount: ticket.ticket_type.credit) unless ticket.ticket_type.credit.nil?
        flash[:notice] = I18n.t('alerts.created')
        redirect_to customer_root_url
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
    @admission.unassign!
    @credit_log = CreditLog.create(customer_id: current_customer.id, transaction_type: CreditLog::TICKET_UNASSIGNMENT, amount: -@admission.ticket.ticket_type.credit) unless @admission.ticket.ticket_type.credit.nil?
    flash[:notice] = I18n.t('alerts.unassigned')
    redirect_to customer_root_url
  end

  private

  def check_has_not_admissions!
    if !current_customer.assigned_admission.nil?
      flash.now[:error] = I18n.t('alerts.created')
      redirect_to customer_root_path
    end
  end

end
