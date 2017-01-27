class Events::TicketAssignmentsController < Events::BaseController
  def create
    @code = permitted_params[:code].strip
    @ticket = @current_event.tickets.find_by(code: @code)
    render(:new) && return unless can_assign?(@ticket)

    @ticket.assign_customer(current_customer, :portal, current_customer)
    redirect_to(customer_root_path(@current_event), notice: "Ticket assigned successfully")
  end

  def destroy
    @ticket = @current_event.tickets.find(params[:id])
    @ticket.unassign_customer(:portal, current_customer)
    redirect_to customer_root_path(@current_event), notice: "Previous assignation"
  end

  private

  def can_assign?(ticket)
    flash.now[:error] = case
                          when ticket.blank? then "Ticket not found. If you have purchased it within the last 48 hours, please try again later until we update your purchase. Otherwise contact support." # rubocop:disable Metrics/LineLength
                          when ticket.ticket_type&.catalog_item.nil? then "The ticket you entered is still being processed by our system and cannot being assigned yet. Please, come back later or contact support" # rubocop:disable Metrics/LineLength
                          when ticket.banned? then "Ticket is blacklisted"
                          when ticket.customer then "Ticket already assigned"
                        end

    flash.now[:error].nil?
  end

  def permitted_params
    params.require(:ticket).permit(:code)
  end
end
