class Admins::Events::StationItemsController < Admins::Events::BaseController
  def index
    @station = current_event.stations.find(params[:station_id])
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
                                             station_parameter_attributes: [:station_id])
    @topup_credit = item_class.camelcase.constantize.create(atts)
    redirect_to add_items_admins_event_station_path(current_event, params[:id])
  end

  def update
    item_class = params[:item_type]
    atts = params.require(item_class).permit(:price, :amount)
    @item = item_class.camelcase.constantize.find(params[:id]).update_attributes(atts)
    render json: @item
  end

  def destroy
    @station = current_event.stations.find(params[:id])
  end
end
