class Admins::Events::StationItemsController < Admins::Events::BaseController
  def index
    @station = @current_event.stations.find(params[:station_id])
    @items = @station.topup_credits +
             @station.station_catalog_items +
             @station.station_products +
             @station.access_control_gates
  end

  def create
    item_class = params[:item_type]
    atts = params.require(item_class).permit(:direction,
                                             :access_id,
                                             :catalog_item_id,
                                             :price,
                                             :product_id,
                                             :amount,
                                             :credit_id,
                                             :station_id)
    @item = item_class.camelcase.constantize.new(atts)
    flash[:error] = @item.errors.full_messages.to_sentence unless @item.save
    redirect_to admins_event_station_station_items_path(@current_event, params[:station_id])
  end

  def update
    item_class = params[:item_type]
    atts = params.require(item_class).permit(:price, :amount)
    @item = item_class.camelcase.constantize.find(params[:id])

    respond_to do |format|
      if @item.update(atts)
        format.json { render status: :ok, json: @item }
      else
        format.json { render status: :unprocessable_entity, json: @item }
      end
    end
  end

  def sort
    item_class = params[:item_type]
    params[:order].each do |_key, value|
      item_class.camelcase.constantize.find(value[:id]).update(position: value[:position])
    end
    render nothing: true
  end

  def visibility
    item_class = params[:item_type]
    @item = item_class.camelcase.constantize.find(params[:station_item_id])
    @item.update(hidden: !@item.hidden?)

    path = admins_event_station_station_items_path(@current_event, params[:station_id])
    redirect_to path, notice: I18n.t("alerts.updated")
  end

  def destroy
    item_class = params[:item_type]
    @item = item_class.camelcase.constantize.find(params[:id]).destroy
    redirect_to admins_event_station_station_items_path(@current_event, params[:station_id])
  end
end
