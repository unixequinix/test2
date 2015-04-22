class Admin::TicketsController < Admin::BaseController

  def index
    @tickets = Ticket.all
  end

  def show
    @ticket = Ticket.find(params[:id])
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(permitted_params)
    if @ticket.save
      flash[:notice] = "created TODO"
      redirect_to admin_ticket_url(@ticket)
    else
      flash[:error] = "ERROR TODO"
      render :new
    end
  end

  def edit
    @ticket = Ticket.find(params[:id])
  end

  def update
    @ticket = Ticket.find(params[:id])
    if @ticket.update(permitted_params)
      flash[:notice] = "updated TODO"
      redirect_to admin_tickets_url
    else
      flash[:error] = "ERROR"
      render :edit
    end
  end

  def destroy
    @ticket = Ticket.find(params[:id])
    @ticket.destroy!
    flash[:notice] = "destroyed TODO"
    redirect_to admin_tickets_url
  end

  private

  def permitted_params
    params.require(:ticket).permit(:number, :ticket_type_id)
  end

end
