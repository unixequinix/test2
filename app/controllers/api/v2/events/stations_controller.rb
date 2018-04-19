module Api::V2
  class Events::StationsController < BaseController
    before_action :set_station, only: %i[show update destroy]

    # GET api/v2/events/:event_id/stations
    def index
      @stations = @current_event.stations
      authorize @stations

      paginate json: @stations
    end

    # GET api/v2/events/:event_id/stations/:id
    def show
      render json: @station, serializer: StationSerializer
    end

    # POST api/v2/events/:event_id/stations
    def create
      @station = @current_event.stations.new(station_params)
      authorize @station

      @station.errors.add(:category, "Must be 'bar' or 'vendor'") unless station_params[:category].in?(%w[bar vendor])
      if @station.save
        render json: @station, status: :created, location: [:admins, @current_event, @station]
      else
        render json: @station.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT api/v2/events/:event_id/stations/:id
    def update
      if station_params[:category].in?(%w[bar vendor]) && @station.update(station_params)
        render json: @station
      else
        @station.errors.add(:category, "Must be 'bar' or 'vendor'")
        render json: @station.errors, status: :unprocessable_entity
      end
    end

    # DELETE api/v2/events/:event_id/stations/:id
    def destroy
      @station.destroy
      head(:ok)
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_station
      @station = @current_event.stations.find(params[:id])
      authorize @station
    end

    # Only allow a trusted parameter "white list" through.
    def station_params
      params.require(:station).permit(:name, :category, :location, :reporting_category, :address, :registration_num, :official_name, :hidden)
    end
  end
end
