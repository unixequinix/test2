class Events::TicketsController < Events::EventsController
  def show
    @ticket = @current_event.tickets.find_by(id: params[:id], customer: current_customer)
    @item = @ticket.ticket_type&.catalog_item
  end
end
