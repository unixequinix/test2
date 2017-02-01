# rubocop:disable Metrics/ClassLength
class Admins::Events::TicketsController < Admins::Events::BaseController
  before_action :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html
      format.csv do
        tickets = Ticket.query_for_csv(@current_event)
        redirect_to(admins_event_tickets_path(@current_event)) && return if tickets.empty?

        send_data(CsvExporter.to_csv(tickets))
      end
    end
  end

  def search
    render :index
  end

  def show
    assoc = { ticket_type: [company_event_agreement: :company] }
    @ticket = @current_event.tickets.includes(:customer, assoc).find(params[:id])
    @catalog_item = @ticket.ticket_type&.catalog_item
  end

  def new
    @ticket = Ticket.new
  end

  def create
    @ticket = Ticket.new(permitted_params)
    if @ticket.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_tickets_url
    else
      flash.now[:error] = I18n.t("alerts.error")
      render :new
    end
  end

  def edit
    @ticket = @current_event.tickets.find(params[:id])
  end

  def update
    @ticket = @current_event.tickets.find(params[:id])
    if @ticket.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_ticket_url(@current_event, @ticket)
    else
      flash.now[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def destroy
    @ticket = @current_event.tickets.find(params[:id])
    if @ticket.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = @ticket.errors.full_messages.join(". ")
    end
    redirect_to admins_event_tickets_url
  end

  def destroy_multiple
    tickets = params[:tickets]
    if tickets
      @current_event.tickets.where(id: tickets.keys).each do |ticket|
        flash[:error] = ticket.errors.full_messages.join(". ") unless ticket.destroy
      end
    end
    redirect_to admins_event_tickets_url
  end

  def import # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    path = admins_event_tickets_path(@current_event)
    redirect_to(path, alert: t("admin.tickets.import.empty_file")) && return unless params[:file]
    file = params[:file][:data].tempfile.path

    begin
      CSV.foreach(file, headers: true, col_sep: ";", encoding: "ISO8859-1:utf-8").with_index do |row, _i|
        c_name = row.field("company_name")
        com = Company.find_by("LOWER(name) = ?", c_name.downcase) || Company.create!(name: c_name)
        agree = com.company_event_agreements.find_or_create_by!(event: @current_event)

        ticket_type_atts = {
          name: row.field("ticket_type"),
          company_code: row.field("company_code"),
          company_event_agreement: agree
        }
        ticket_type = @current_event.ticket_types.find_or_create_by!(ticket_type_atts)

        ticket_atts = {
          code: row.field("reference"),
          ticket_type: ticket_type,
          purchaser_first_name: row.field("first_name"),
          purchaser_last_name: row.field("last_name"),
          purchaser_email: row.field("email")
        }
        @current_event.tickets.find_or_create_by!(ticket_atts)
      end
    rescue
      return redirect_to(path, alert: t("admin.tickets.import.error"))
    end

    redirect_to(path, notice: t("admin.tickets.import.success"))
  end

  def sample_csv
    header = %w(ticket_type company_code company_name reference first_name last_name email)
    data = [["VIP Night", "098", "Glownet Tickets", "0011223344", "Jon", "Snow", "jon@snow.com"],
            ["VIP Day", "099", "Glownet Tickets", "4433221100", "Arya", "Stark", "arya@stark.com"]]

    csv_file = CsvExporter.sample(header, data)
    respond_to do |format|
      format.csv { send_data(csv_file) }
    end
  end

  def ban
    ticket = @current_event.tickets.find(params[:id])
    ticket.update(banned: true)
    redirect_to(admins_event_tickets_url)
  end

  def unban
    ticket = @current_event.tickets.find(params[:id])
    ticket.update(banned: false)
    redirect_to(admins_event_tickets_url)
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Ticket".constantize.model_name,
      fetcher: @current_event.tickets,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [customer: [:active_gtag]],
      context: view_context
    )
  end

  def permitted_params
    params.require(:ticket).permit(:event_id, :code, :ticket_type_id, :redeemed, :banned, :purchaser_first_name, :purchaser_last_name, :purchaser_email, :catalog_item_id) # rubocop:disable Metrics/LineLength
  end
end
