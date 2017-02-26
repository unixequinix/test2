class Events::GtagsController < Events::EventsController
  def show
    @gtag = @current_event.gtags.find_by(id: params[:id], customer: current_customer)
    @products = @gtag.ticket_type&.catalog_item&.all_catalog_items || []
  end
end
