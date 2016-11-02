class Events::TicketsController < Events::BaseController
  def show
    @ticket = current_event.tickets.find_by(id: params[:id], profile: current_profile.id)

    ticket_catalog_item = @ticket.company_ticket_type.credential_type&.catalog_item

    @products = if ticket_catalog_item&.catalogable_type == "Pack"
                  ticket_catalog_item.catalogable.pack_catalog_items.includes(:catalog_item).map(&:catalog_item)
                else
                  [catalog_item]
                end
  end
end
