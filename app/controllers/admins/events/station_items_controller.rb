class Admins::Events::StationItemsController < Admins::Events::BaseController
  before_action :set_item_class, except: [:index, :find_product]
  before_action :set_station, only: [:index, :create]

  def index
    skip_authorization
  end

  def create
    params[:station_product][:product_id] = current_event.products.find_or_create_by!(name: params[:station_product][:product_name]).id if params[:item_type].eql?("station_product") # rubocop:disable Metrics/LineLength
    @item = @klass.new(permitted_params)

    authorize @item
    if @item.save
      redirect_to admins_event_station_station_items_path(@current_event, @item.station), notice: t("alerts.created")
    else
      flash.now[:alert] = t("alerts.error")
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

  def visibility
    @item = @klass.find(params[:station_item_id])
    authorize @item
    @item.toggle!(:hidden)
    redirect_to admins_event_station_station_items_path(@current_event, @item.station), notice: t("alerts.updated")
  end

  def destroy
    @item = @klass.find(params[:id])
    authorize @item

    if @item.destroy
      flash[:notice] = t("alerts.destroyed")
    else
      flash[:error] = @pack.errors.full_messages.to_sentence
    end
    redirect_to admins_event_station_station_items_path(@current_event, @item.station)
  end

  def find_product
    skip_authorization
    @products = @current_event.products.where("name LIKE '%#{params[:product_name]}%'")
    render partial: "product_results"
  end

  def sort
    skip_authorization
    params[:order].to_unsafe_h.each_pair do |_key, value|
      next unless value[:id]
      @klass.find(value[:id]).update(position: value[:position].to_i - 1)
    end
    head(:ok)
  end

  private

  def set_station
    @station = @current_event.stations.find(params[:station_id])
    @items = @station.all_station_items
    @items.sort_by!(&@items.first.class.sort_column) if @items.first
  end

  def set_item_class
    @klass = params[:item_type].camelcase.constantize
  end

  def permitted_params
    params.require(params[:item_type]).permit(:direction,
                                              :access_id,
                                              :catalog_item_id,
                                              :price,
                                              :product_id,
                                              :product_name,
                                              :amount,
                                              :credit_id,
                                              :station_id)
  end
end
