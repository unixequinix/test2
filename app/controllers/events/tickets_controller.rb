class Events::TicketsController < Events::EventsController
  def show
    @ticket = @current_event.tickets.find_by(id: params[:id], customer: @current_customer)
    redirect_to(event_path(@current_event), alert: "Ticket not found") && return unless @ticket
    @item = @ticket.ticket_type&.catalog_item
  end
end
