class Admins::EventSeriesController < Admins::BaseController
  before_action :set_event_series, only: %i[show edit update destroy copy_data copy_serie add_event remove_event]

  # GET /event_series
  # GET /event_series.json
  def index
    @event_series = EventSerie.all
    authorize(@event_series)
  end

  # GET /event_series/:id
  # GET /event_series/:id.json
  def show
    @events = Event.where(event_serie: nil).where.not(state: "closed").order(:name)
  end

  # GET /event_series/new
  def new
    @event_serie = EventSerie.new
    authorize(@event_serie)
  end

  # GET /event_series/:id/edit
  def edit; end

  # POST /event_series
  # POST /event_series.json
  def create
    @event_serie = EventSerie.new(permitted_params)
    authorize(@event_serie)

    respond_to do |format|
      if @event_serie.save
        format.html { redirect_to [:admins, @event_serie], notice: 'Event series was successfully created.' }
        format.json { render :show, status: :created, location: [:admins, @event_serie] }
      else
        format.html { render :new }
        format.json { render json: @event_serie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_series/:id
  # PATCH/PUT /event_series/:id.json
  def update
    respond_to do |format|
      if @event_serie.update(permitted_params)
        format.html { redirect_to [:admins, @event_serie], notice: 'Event series was successfully updated.' }
        format.json { render :show, status: :ok, location: [:admins, @event_serie] }
      else
        format.html { render :edit }
        format.json { render json: @event_serie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_series/:id
  # DELETE /event_series/:id.json
  def destroy
    @event_serie.destroy
    respond_to do |format|
      format.html { redirect_to admins_event_series_index_url, notice: 'Event series was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_event
    @event = Event.find(params[:event_id])
    @event.update!(event_serie: @event_serie)
    redirect_to request.referer, notice: "Event was succesfully added"
  end

  def remove_event
    @event = Event.find(params[:event_id])
    @event.update!(event_serie: nil)
    redirect_to request.referer, notice: "Event was succesfully removed"
  end

  def copy_data
    @events = @event_serie.events.order(:name)
  end

  def copy_serie
    new_event = Event.find(params[:new_id])
    old_event = Event.find(params[:old_id])

    if old_event == new_event
      redirect_to copy_data_admins_event_series_path(@event_serie), alert: "Both events cannot be the same"
    else
      Creators::EventSerieJob.perform_later(new_event, old_event, params[:selection].split(" "))
      redirect_to admins_event_series_path(@event_serie), notice: "Event data copying... please wait"
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event_series
    @event_serie = EventSerie.find(params[:id])
    authorize(@event_serie)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def permitted_params
    params.require(:event_serie).permit(:name)
  end
end
