class Admins::Events::TicketsController < Admins::Events::BaseController
  before_action :set_ticket, except: [:index, :new, :create, :import, :sample_csv, :destroy_multiple]
  def index
    @tickets = @current_event.tickets
    authorize @tickets
    @tickets = @tickets.page(params[:page])
    respond_to do |format|
      format.html
      format.csv { send_data(CsvExporter.to_csv(Ticket.query_for_csv(@current_event))) }
    end
  end

  def show
    @catalog_item = @ticket.ticket_type&.catalog_item
  end

  def new
    @ticket = @current_event.tickets.new
    authorize @ticket
  end

  def create
    @ticket = @current_event.tickets.new(permitted_params)
    authorize @ticket
    if @ticket.save
      redirect_to admins_event_tickets_path, notice: I18n.t("alerts.created")
    else
      flash.now[:error] = I18n.t("alerts.error")
      render :new
    end
  end

  def update
    if @ticket.update(permitted_params)
      redirect_to admins_event_ticket_path(@current_event, @ticket), notice: I18n.t("alerts.updated")
    else
      flash.now[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def destroy
    respond_to do |format|
      if @ticket.destroy
        format.html { redirect_to admins_event_tickets_path, notice: 'Ticket was successfully deleted.' }
        format.json { render :show, status: :ok, location: admins_event_tickets_path }
      else
        redirect_to [:admins, @current_event, @ticket], error: @ticket.errors.full_messages.to_sentence
      end
    end
  end

  def destroy_multiple
    @current_event.tickets.where(id: params[:tickets].to_h.keys).each do |ticket|
      authorize ticket
      flash[:error] = ticket.errors.full_messages.to_sentence unless ticket.destroy
    end
    redirect_to admins_event_tickets_path
  end

  def import # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    authorize @current_event.tickets.new
    path = admins_event_tickets_path(@current_event)
    redirect_to(path, alert: t("admin.tickets.import.empty_file")) && return unless params[:file]
    file = params[:file][:data].tempfile.path

    begin
      CSV.foreach(file, headers: true, col_sep: ";", encoding: "ISO8859-1:utf-8").with_index do |row, _i|
        c_name = row.field("company_name")
        com = Company.find_by("LOWER(name) = ?", c_name.downcase) || Company.create!(name: c_name)
        agree = com.company_event_agreements.find_or_create_by!(event: @current_event, state: "granted")

        ticket_type_atts = { name: row.field("ticket_type"), company_code: row.field("company_code"), company_event_agreement: agree }
        ticket_type = @current_event.ticket_types.find_or_create_by!(ticket_type_atts)

        ticket_atts = { code: row.field("reference"), ticket_type: ticket_type, purchaser_first_name: row.field("first_name"), purchaser_last_name: row.field("last_name"), purchaser_email: row.field("email") } # rubocop:disable Metrics/LineLength
        @ticket = @current_event.tickets.find_or_create_by!(ticket_atts)
      end
    rescue
      return redirect_to(path, alert: t("admin.tickets.import.error"))
    end

    redirect_to(path, notice: t("admin.tickets.import.success"))
  end

  def sample_csv
    authorize @current_event.tickets.new
    header = %w(ticket_type company_code company_name reference first_name last_name email)
    data = [["VIP Night", "098", "Glownet Tickets", "0011223344", "Jon", "Snow", "jon@snow.com"], ["VIP Day", "099", "Glownet Tickets", "4433221100", "Arya", "Stark", "arya@stark.com"]] # rubocop:disable Metrics/LineLength

    respond_to do |format|
      format.csv { send_data(CsvExporter.sample(header, data)) }
    end
  end

  def ban
    @ticket.update(banned: true)
    redirect_to(admins_event_tickets_path)
  end

  def unban
    @ticket.update(banned: false)
    redirect_to(admins_event_tickets_path)
  end

  private

  def set_ticket
    @ticket = @current_event.tickets.find(params[:id])
    authorize @ticket
  end

  def permitted_params
    params.require(:ticket).permit(:event_id, :code, :ticket_type_id, :redeemed, :banned, :purchaser_first_name, :purchaser_last_name, :purchaser_email, :catalog_item_id) # rubocop:disable Metrics/LineLength
  end
end
