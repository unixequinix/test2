class Events::TicketAssignmentsController < Events::EventsController
  def create
    @code = permitted_params[:code].strip
    @ticket = @current_event.tickets.find_by(code: @code)
    render(:new) && return unless can_assign?(@ticket)

    @ticket.assign_customer(current_customer, :portal, current_customer)
    @ticket.assign_gtag
    redirect_to(customer_root_path(@current_event), notice: t("alerts.credential.assigned", item: "Ticket"))
  end

  def destroy
    @ticket = @current_event.tickets.find(params[:id])
    @ticket.unassign_customer(:portal, current_customer)
    redirect_to customer_root_path(@current_event), notice: t("alerts.credential.unassigned", item: "Ticket")
  end

  private

  def can_assign?(ticket)
    flash.now[:error] = case
                          when ticket.blank? then t("alerts.credential.not_found", item: "Ticket")
                          when ticket.ticket_type&.catalog_item.nil? then t("alerts.credential.no_item_assigned", item: "ticket")
                          when ticket.banned? then t("alerts.credential.blacklisted", item: "Ticket")
                          when ticket.customer then t("alerts.credential.already_assigned", item: "Ticket")
                        end

    flash.now[:error].nil?
  end

  def permitted_params
    params.require(:ticket).permit(:code)
  end
end
