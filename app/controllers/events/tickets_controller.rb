class Events::TicketsController < Events::BaseController
  def show
    @ticket = current_event.tickets.find_by(id: params[:id], customer: current_customer)

    ticket_catalog_item = @ticket.ticket_type&.catalog_item
    @products = ticket_catalog_item&.is_a?(Pack) ? ticket_catalog_item.catalog_items : [catalog_item]
  end
end
