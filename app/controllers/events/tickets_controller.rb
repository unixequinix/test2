class Events::TicketsController < Events::EventsController
  def show
    @ticket = @current_event.tickets.find_by(id: params[:id], customer: current_customer)
    @products = @ticket.ticket_type&.catalog_item&.all_catalog_items
  end
end
