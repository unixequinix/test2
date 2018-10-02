class Events::GtagsController < Events::EventsController
  before_action :set_gtag, only: %i[show ban]
  def show
    @gtag = @current_event.gtags.find_by(id: params[:id], customer: @current_customer)
    @item = @gtag.ticket_type&.catalog_item
  end

  def ban
    flash[:notice] = t("gtag_unsubscribe.flash_message")
    @gtag.update!(banned: true)
    redirect_to action: :show
  end

  private

  def set_gtag
    @gtag = @current_event.gtags.find_by(id: params[:id], customer: @current_customer)
  end
end
