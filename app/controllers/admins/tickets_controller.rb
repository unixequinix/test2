class Admins::TicketsController < Admins::BaseController

  def index
    @q = Ticket.search(params[:q])
    @tickets = @q.result(distinct: true).page(params[:page]).includes(:ticket_type, :assigned_admission)
    respond_to do |format|
      format.html
      format.csv { send_data @tickets.to_csv }
    end
  end

  def search
    @q = Ticket.search(params[:q])
    @tickets = @q.result(distinct: true).page(params[:page]).includes(:ticket_type, :assigned_admission)
    render :index
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(permitted_params)
    if @ticket.save
      flash[:notice] = I18n.t('alerts.created')
      redirect_to admins_tickets_url
    else
      flash[:error] = I18n.t('alerts.error')
      render :new
    end
  end

  def edit
    @ticket = Ticket.find(params[:id])
  end

  def update
    @ticket = Ticket.find(params[:id])
    if @ticket.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_tickets_url
    else
      flash[:error] = I18n.t('alerts.error')
      render :edit
    end
  end

  def destroy
    @ticket = Ticket.find(params[:id])
    if @ticket.destroy
      flash[:notice] = I18n.t('alerts.destroyed')
      redirect_to admins_tickets_url
    else
      flash[:error] = @ticket.errors.full_messages.join(". ")
      redirect_to admins_tickets_url
    end
  end

  def destroy_multiple
    tickets = params[:tickets]
    Ticket.where(id: tickets.keys).each do |ticket|
      if !ticket.destroy
        flash[:error] = ticket.errors.full_messages.join(". ")
      end
    end
    redirect_to admins_tickets_url
  end

  def import
    import_result = Ticket.import_csv(params[:file])
    if import_result
      flash[:notice] = I18n.t('alerts.imported')
      redirect_to admins_tickets_url
    else
      flash[:error] = import_result
      redirect_to admins_tickets_url
    end
  end

  private

  def permitted_params
    params.require(:ticket).permit(:number, :ticket_type_id, :purchaser_name, :purchaser_surname, :purchaser_email)
  end

end
