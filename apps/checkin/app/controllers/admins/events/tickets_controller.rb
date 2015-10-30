class Admins::Events::TicketsController < Admins::Events::CheckinBaseController

  def index
    all_tickets = @fetcher.tickets
    @q = all_tickets.search(params[:q])
    @tickets = @q.result(distinct: true).page(params[:page]).includes(:ticket_type, :assigned_admission)
    @tickets_count = all_tickets.count
    respond_to do |format|
      format.html
      format.csv { send_data(Csv::CsvExporter.to_csv(@fetcher.tickets))}
    end
  end

  def search
    all_tickets = @fetcher.tickets
    @q = all_tickets.search(params[:q])
    @tickets = @q.result(distinct: true).page(params[:page]).includes(:ticket_type, :assigned_admission)
    @tickets_count = all_tickets.count
    render :index
  end

  def show
    @ticket = Ticket.includes(admissions: [:customer_event_profile, customer_event_profile: :customer]).find(params[:id])
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(permitted_params)
    if @ticket.save
      flash[:notice] = I18n.t('alerts.created')
      redirect_to admins_event_tickets_url
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
      redirect_to admins_event_ticket_url(current_event, @ticket)
    else
      flash[:error] = I18n.t('alerts.error')
      render :edit
    end
  end

  def destroy
    @ticket = Ticket.find(params[:id])
    if @ticket.destroy
      flash[:notice] = I18n.t('alerts.destroyed')
      redirect_to admins_event_tickets_url
    else
      flash[:error] = @ticket.errors.full_messages.join(". ")
      redirect_to admins_event_tickets_url
    end
  end

  def destroy_multiple
    if tickets = params[:tickets]
      Ticket.where(id: tickets.keys).each do |ticket|
        if !ticket.destroy
          flash[:error] = ticket.errors.full_messages.join(". ")
        end
      end
    end
    redirect_to admins_event_tickets_url
  end

  private

  def permitted_params
    params.require(:ticket).permit(:event_id, :number, :ticket_type_id, :purchaser_name, :purchaser_surname, :purchaser_email)
  end

end
