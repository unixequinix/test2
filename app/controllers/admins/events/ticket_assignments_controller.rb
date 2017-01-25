class Admins::Events::TicketAssignmentsController < Admins::Events::BaseController
  before_action :set_customer, only: [:new, :create]

  def create
    @code = permitted_params[:code].strip
    @ticket = @current_event.tickets.find_by(code: @code)

    errors = []
    errors << I18n.t("alerts.admissions") if @ticket.blank?
    errors << I18n.t("alerts.ticket_without_credential") if @ticket.ticket_type&.catalog_item.nil?
    errors << I18n.t("alerts.ticket_banned") if @ticket.banned?
    errors << I18n.t("alerts.ticket_already_assigned") if @ticket.customer

    if errors.any?
      flash.now[:errors] = errors.to_sentence
      render(:new)
    else
      @ticket.assign_customer(@customer, :admin, current_admin)
      redirect_to(admins_event_customer_path(@current_event, @customer), notice: I18n.t("alerts.ticket_assigned"))
    end
  end

  def destroy
    @ticket = Ticket.find(params[:id])
    @ticket.unassign_customer(:admin, current_admin)
    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to :back
  end

  private

  def set_customer
    @customer = @current_event.customers.find(params[:id])
  end

  def permitted_params
    params.permit(:code).merge(event_id: @current_event.id)
  end
end
