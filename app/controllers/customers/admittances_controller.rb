class Customers::AdmittancesController < Customers::BaseController
  before_action :check_has_not_admissions!, only: [:new, :create]
  def new
    @admittance = Admittance.new
  end

  def create
    ticket = Ticket.find_by(number: params[:ticket_number].strip)
    if !ticket.nil?
      @admittance = current_admission.admittances.build(ticket: ticket)
      if @admittance.save
        @credit_log = CreditLog.create(customer_id: current_customer.id, transaction_type: CreditLog::TICKET_ASSIGNMENT, amount: ticket.ticket_type.credit) unless ticket.ticket_type.credit.nil?
        flash[:notice] = I18n.t('alerts.created')
        redirect_to customer_root_url
      else
        flash[:error] = @admittance.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = I18n.t('alerts.admissions', companies: TicketType.companies.join(', '))
      render :new
    end
  end

  def destroy
    @admittance = Admittance.find(params[:id])
    @admittance.unassign!
    @credit_log = CreditLog.create(customer_id: current_customer.id, transaction_type: CreditLog::TICKET_UNASSIGNMENT, amount: -@admittance.ticket.ticket_type.credit) unless @admittance.ticket.ticket_type.credit.nil?
    flash[:notice] = I18n.t('alerts.unassigned')
    redirect_to customer_root_url
  end

  private

  def check_has_not_admissions!
    if !current_customer.assigned_admission.nil?
      redirect_to customer_root_path, flash: { error: I18n.t('alerts.already_assigned') }
    end
  end

end
