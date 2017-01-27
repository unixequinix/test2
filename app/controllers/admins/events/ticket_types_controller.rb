class Admins::Events::TicketTypesController < Admins::Events::BaseController
  before_action :set_ticket_type, except: [:index, :new, :create, :visibility]
  before_action :set_catalog_items, except: [:index, :destroy, :visibility]

  def index
    @ticket_types = @current_event.ticket_types
    authorize @ticket_types
    @ticket_types = @ticket_types.page(params[:page])
  end

  def new
    @ticket_type = TicketType.new
    authorize @ticket_type
  end

  def create
    @ticket_type = TicketType.new(permitted_params)
    authorize @ticket_type
    if @ticket_type.save
      redirect_to admins_event_ticket_types_path, notice: I18n.t("alerts.created")
    else
      flash.now[:error] = @ticket_type.errors.full_messages.join(". ")
      render :new
    end
  end

  def update
    if @ticket_type.update(permitted_params)
      redirect_to admins_event_ticket_types_path, notice: I18n.t("alerts.updated")
    else
      flash.now[:error] = @ticket_type.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    if @ticket_type.destroy
      redirect_to admins_event_ticket_types_path(@current_event), notice: I18n.t("alerts.destroyed")
    else
      redirect_to admins_event_ticket_types_path(@current_event, @ticket_type), error: @ticket_type.errors.full_messages.to_sentence
    end
  end

  def visibility
    @ticket_type = @current_event.ticket_types.find(params[:ticket_type_id])
    authorize @ticket_type
    @ticket_type.hidden? ? @ticket_type.show! : @ticket_type.hide!
    redirect_to admins_event_ticket_types_path(@current_event), notice: I18n.t("alerts.updated")
  end

  private

  def set_catalog_items
    @catalog_items = @current_event.catalog_items
    @agreements = @current_event.company_event_agreements
  end

  def set_ticket_type
    @ticket_type = @current_event.ticket_types.find(params[:id])
    authorize @ticket_type
  end

  def permitted_params
    params.require(:ticket_type).permit(:event_id, :company_id, :name, :company_code, :company_event_agreement_id, :catalog_item_id)
  end
end
