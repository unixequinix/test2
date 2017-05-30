class Admins::Events::AccessesController < Admins::Events::BaseController
  before_action :set_access, except: %i[index new create]

  def index
    @accesses = @current_event.accesses.page(params[:page])
    authorize @accesses
  end

  def new
    @access = @current_event.accesses.new(mode: "permanent")
    authorize @access
  end

  def create
    @access = @current_event.accesses.new(permitted_params)
    authorize @access

    if @access.save
      flash[:notice] = t("alerts.created")
      redirect_to admins_event_accesses_path
    else
      flash.now[:alert] = t("alerts.error")
      render :new
    end
  end

  def update
    respond_to do |format|
      if @access.update(permitted_params)
        flash[:notice] = t("alerts.updated")
        format.html { redirect_to admins_event_accesses_path }
        format.json { render json: @access }
      else
        flash.now[:alert] = t("alerts.error")
        format.html { render :edit }
        format.json { render json: { errors: @access.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @access.destroy
        format.html { redirect_to admins_event_accesses_path, notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to [:admins, @current_event, @access], alert: @access.errors.full_messages.to_sentence }
        format.json { render json: { errors: @access.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_access
    @access = @current_event.accesses.find(params[:id])
    authorize @access
  end

  def permitted_params
    params.require(:access).permit(:name, :mode)
  end
end
