class Admins::Events::TicketTypesController < Admins::Events::BaseController
  before_action :set_ticket_type, except: %i[index new create]
  before_action :set_catalog_items, except: [:destroy]

  def unban
    @ticket_type.tickets.update_all(banned: false)
    redirect_to [:admins, @current_event, @ticket_type], notice: "All tickets successfully unbanned"
  end

  def index
    @ticket_types = @current_event.ticket_types.order(%i[company_id name])
    authorize @ticket_types
    @ticket_types = @ticket_types.page(params[:page])
  end

  def show
    @q = @ticket_type.tickets.order(created_at: :desc).ransack(params[:q])
    @tickets = @q.result
    @tickets = @tickets.page(params[:page])
  end

  def new
    @ticket_type = @current_event.ticket_types.new
    authorize @ticket_type
  end

  def create
    @ticket_type = @current_event.ticket_types.new(permitted_params)
    authorize @ticket_type
    if @ticket_type.save
      redirect_to admins_event_ticket_types_path, notice: t("alerts.created")
    else
      flash.now[:alert] = @ticket_type.errors.full_messages.join(". ")
      render :new
    end
  end

  def update
    respond_to do |format|
      if @ticket_type.update(permitted_params)
        format.html { redirect_to admins_event_ticket_types_path, notice: t("alerts.updated") }
        format.json { render json: @ticket_type }
      else
        flash.now[:alert] = t("alerts.errors")
        format.html { render :edit }
        format.json { render json: { errors: @ticket_type.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @ticket_type.destroy
      redirect_to admins_event_ticket_types_path(@current_event), notice: t("alerts.destroyed")
    else
      redirect_to admins_event_ticket_types_path(@current_event, @ticket_type), alert: @ticket_type.errors.full_messages.to_sentence
    end
  end

  private

  def set_catalog_items
    @catalog_items = @current_event.catalog_items
  end

  def set_ticket_type
    @ticket_type = @current_event.ticket_types.find(params[:id])
    authorize @ticket_type
  end

  def permitted_params
    params.require(:ticket_type).permit(:company_id, :name, :company_code, :catalog_item_id, :hidden)
  end
end
