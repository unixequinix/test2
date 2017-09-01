class Api::V2::Events::StationsController < Api::V2::BaseController
  before_action :set_station, only: %i[show update destroy add_product remove_product update_product]

  # GET /stations
  def index
    @stations = @current_event.stations
    authorize @stations

    render json: @stations
  end

  # GET /stations/1
  def show
    render json: @station
  end

  # POST /stations
  def create
    @station = @current_event.stations.new(station_params)
    authorize @station

    if @station.save
      render json: @station, status: :created, location: [:admins, @current_event, @station]
    else
      render json: @station.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /stations/1
  def update
    if @station.update(station_params)
      render json: @station
    else
      render json: @station.errors, status: :unprocessable_entity
    end
  end

  # DELETE /stations/1
  def destroy
    @station.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_station
    @station = @current_event.stations.find(params[:id])
    authorize @station
  end

  # Only allow a trusted parameter "white list" through.
  def station_params
    params.require(:station).permit(:name, :location, :category, :reporting_category, :address, :registration_num, :official_name, :hidden)
  end

  def product_params
    params.require(:product).permit(:name, :description, :vat, :is_alcohol, :price, :position)
  end
end
