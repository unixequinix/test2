class Events::GtagsController < Events::EventsController
  def show
    @gtag = @current_event.gtags.find_by(id: params[:id], customer: current_customer)
    @item = @gtag.ticket_type&.catalog_item
  end
end
