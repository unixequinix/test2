class Admins::Events::AccessesController < Admins::Events::BaseController
  before_action :set_access, except: [:index, :new, :create]

  def index
    @accesses = @current_event.accesses.page(params[:page])
    authorize @accesses
  end

  def new
    @access = @current_event.accesses.new
    authorize @access
  end

  def create
    @access = @current_event.accesses.new(permitted_params)
    authorize @access

    if @access.save
      flash[:notice] = t("alerts.created")
      redirect_to admins_event_accesses_path
    else
      flash.now[:error] = @access.errors.full_messages.join(". ")
      render :new
    end
  end

  def update
    if @access.update(permitted_params)
      flash[:notice] = t("alerts.updated")
      redirect_to admins_event_accesses_path
    else
      flash.now[:error] = @access.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    respond_to do |format|
      if @access.destroy
        format.html { redirect_to admins_event_accesses_path, notice: 'Access was successfully deleted.' }
        format.json { render :show, status: :ok, location: admins_event_accesses_path }
      else
        redirect_to [:admins, @current_event, @access], error: @access.errors.full_messages.to_sentence
      end
    end
  end

  private

  def set_access
    @access = @current_event.accesses.find(params[:id])
    authorize @access
  end

  def permitted_params
    params.require(:access).permit(:name, :initial_amount, :step, :max_purchasable, :min_purchasable, :mode)
  end
end
