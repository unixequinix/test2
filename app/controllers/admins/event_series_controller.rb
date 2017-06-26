class Admins::EventSeriesController < Admins::BaseController
  before_action :set_event_serie, only: %i[show edit update destroy]

  def index
    @event_series = EventSerie.all
    authorize @event_series
  end

  def new
    @event_serie = EventSerie.new
    authorize @event_serie
  end

  def create
    @event_serie = EventSerie.new(permitted_params)
    authorize @event_serie

    if @event_serie.save
      flash[:notice] = t("event_serie.created")
      redirect_to admins_event_series_path(@event_serie)
    else
      flash.now[:alert] = t("event_serie.error")
      render :new
    end
  end

  def update
    authorize @event_serie

    if @event_serie.update(permitted_params)
      flash[:notice] = t("event_serie.created")
      redirect_to admins_event_series_path(@event_serie)
    else
      flash.now[:alert] = t("event_serie.error")
      render :edit
    end
  end

  def destroy
    authorize @event_serie

    if @event_serie.destroy
      flash[:notice] = t("event_serie.destroyed")
      redirect_to admins_event_series_index_path
    else
      flash.now[:alert] = t("event_serie.error")
      render :show
    end
  end

  private

  def set_event_serie
    @event_serie = EventSerie.find(params[:id])
    authorize @event_serie
  end

  def permitted_params
    params.require(:event_serie).permit(:name)
  end
end
