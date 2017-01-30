class Admins::Events::StationItemsController < Admins::Events::BaseController
  before_action :set_item_class, except: [:index]
  before_action :set_station, only: [:index, :create]

  def index
    skip_authorization
  end

  def create
    @item = @klass.new(permitted_params)
    authorize @item
    if @item.save
      redirect_to redirect_path, notice: I18n.t("alerts.created")
    else
      flash.now[:alert] = I18n.t("alerts.error")
      render :index
    end
  end

  def update
    @item = @klass.find(params[:id])
    authorize @item
    respond_to do |format|
      if @item.update(params.require(params[:item_type]).permit(:price, :amount))
        format.json { render status: :ok, json: @item }
      else
        format.json { render status: :unprocessable_entity, json: @item }
      end
    end
  end

  def sort
    params[:order].each do |_key, value|
      @item = @klass.find(value[:id])
      authorize @item
      @item.update(position: value[:position])
    end
    render nothing: true
  end

  def visibility
    @item = @klass.find(params[:station_item_id])
    authorize @item
    @item.toggle!(:hidden)
    redirect_to redirect_path, notice: I18n.t("alerts.updated")
  end

  def destroy
    @item = @klass.find(params[:id])
    authorize @item

    if @item.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = @pack.errors.full_messages.to_sentence
    end
    redirect_to admins_event_station_station_items_path(@current_event, @item.station)
  end

  private

  def redirect_path; end

  def set_station
    @station = @current_event.stations.find(params[:station_id])
    @items = @station.all_station_items
  end

  def set_item_class
    @klass = params[:item_type].camelcase.constantize
  end

  def permitted_params
    params.require(params[:item_type]).permit(:direction, :access_id, :catalog_item_id, :price, :product_id, :amount, :credit_id, :station_id)
  end
end
