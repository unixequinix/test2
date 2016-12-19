class Admins::Events::StationItemsController < Admins::Events::BaseController
  before_action :set_item_class, except: [:index]
  before_action :set_station, only: [:index, :create]

  def create
    @item = @klass.new(permitted_params)
    if @item.save
      redirect_to redirect_path, notice: I18n.t("alerts.created")
    else
      flash.now[:alert] = I18n.t("alerts.error")
      render :index
    end
  end

  def update
    @item = @klass.find(params[:id])

    respond_to do |format|
      if @item.update(params.require(params[:item_type]).permit(:price, :amount))
        format.json { render status: :ok, json: @item }
      else
        format.json { render status: :unprocessable_entity, json: @item }
      end
    end
  end

  def sort
    params[:order].each { |_key, value| @klass.find(value[:id]).update(position: value[:position]) }
    render nothing: true
  end

  def visibility
    @item = @klass.find(params[:station_item_id])
    @item.toggle!(:hidden)
    redirect_to redirect_path, notice: I18n.t("alerts.updated")
  end

  def destroy
    @item = @klass.find(params[:id]).destroy
    redirect_to redirect_path, notice: I18n.t("alerts.destroyed")
  end

  private

  def redirect_path
    admins_event_station_station_items_path(@current_event, params[:station_id])
  end

  def set_station
    @station = @current_event.stations.find(params[:station_id])
    @items = @station.all_station_items
  end

  def set_item_class
    @klass = params[:item_type].camelcase.constantize
  end

  def permitted_params
    params.require(params[:item_type])
          .permit(:direction, :access_id, :catalog_item_id, :price, :product_id, :amount, :credit_id, :station_id)
  end
end
