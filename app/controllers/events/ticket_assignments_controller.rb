class Events::TicketAssignmentsController < Events::EventsController
  def new
    @ticket = @current_event.tickets.new
  end

  def create
    @code = permitted_params[:reference].strip
    @ticket = @current_event.tickets.find_or_initialize_by(code: @code)
    @ticket.errors.add(:reference, I18n.t("credentials.same_credential", item: "Ticket")) if @current_customer.can_purchase_item?(@ticket.ticket_type&.catalog_item)
    render(:new) && return unless @ticket.validate_assignation

    @ticket.assign_customer(@current_customer, @current_customer)

    redirect_to(customer_root_path(@current_event), notice: t("credentials.assigned", item: "Ticket"))
  end

  def destroy
    @ticket = @current_event.tickets.find(params[:id])
    @ticket.unassign_customer(current_customer)
    redirect_to customer_root_path(@current_event), notice: t("credentials.unassigned", item: "Ticket")
  end

  private

  def permitted_params
    params.require(:ticket).permit(:reference)
  end
end
