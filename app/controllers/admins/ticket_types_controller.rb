class Admins::TicketTypesController < Admins::BaseController

  def index
    @ticket_types = TicketType.all.includes(:entitlements)
  end

  def new
    @ticket_type = TicketType.new
  end

  def create
    @ticket_type = TicketType.new(permitted_params)
    if @ticket_type.save
      flash[:notice] = "created TODO"
      redirect_to admins_ticket_types_url
    else
      flash[:error] = "ERROR TODO"
      render :new
    end
  end

  def edit
    @ticket_type = TicketType.find(params[:id])
  end

  def update
    @ticket_type = TicketType.find(params[:id])
    if @ticket_type.update(permitted_params)
      flash[:notice] = "updated TODO"
      redirect_to admins_ticket_types_url
    else
      flash[:error] = "ERROR"
      render :edit
    end
  end

  def destroy
    @ticket_type = TicketType.find(params[:id])
    @ticket_type.destroy!
    flash[:notice] = "destroyed TODO"
    redirect_to admins_ticket_types_url
  end

  private

  def permitted_params
    params.require(:ticket_type).permit(:name, :company, :credit, entitlement_ids: [])
  end

end
