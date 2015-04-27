class Admins::TicketsController < Admin::BaseController

  def index
    @q = Ticket.search(params[:q])
    @tickets = @q.result(distinct: true).includes(:ticket_type)
    respond_to do |format|
      format.html
      format.csv { send_data @tickets.to_csv }
    end
  end

  def search
    @q = Ticket.search(params[:q])
    @tickets = @q.result(distinct: true).includes(:ticket_type)
    render :index
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(permitted_params)
    if @ticket.save
      flash[:notice] = "created TODO"
      redirect_to admin_tickets_url
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

  def import
    Ticket.import(params[:file])
    redirect_to admin_tickets_url, notice: "Tickets imported TODO"
  end

  private

  def permitted_params
    params.require(:ticket).permit(:number, :ticket_type_id)
  end

end
