# rubocop:disable Metrics/MethodLength, Metrics/ClassLength, Metrics/ParameterLists
class Admins::Events::TicketsController < Admins::Events::CheckinBaseController
  before_filter :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html
      format.csv { send_data(Csv::CsvExporter.to_csv(Ticket.selected_data(current_event.id))) }
    end
  end

  def search
    render :index
  end

  def show
    @ticket = @fetcher.tickets
                      .includes(credential_assignments: [profile: :customer],
                                company_ticket_type: [company_event_agreement: :company])
                      .find(params[:id])
  end

  def new
    @ticket = Ticket.new
    @ticket.build_purchaser
  end

  def create
    @ticket = Ticket.new(permitted_params)
    if @ticket.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_tickets_url
    else
      @ticket.build_purchaser
      flash.now[:error] = I18n.t("alerts.error")
      render :new
    end
  end

  def edit
    @ticket = @fetcher.tickets.find(params[:id])
  end

  def update
    @ticket = @fetcher.tickets.find(params[:id])
    if @ticket.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_ticket_url(current_event, @ticket)
    else
      flash.now[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def destroy
    @ticket = @fetcher.tickets.find(params[:id])
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
      @fetcher.tickets.where(id: tickets.keys).each do |ticket|
        flash[:error] = ticket.errors.full_messages.join(". ") unless ticket.destroy
      end
    end
    redirect_to admins_event_tickets_url
  end

  def import # rubocop:disable Metrics/AbcSize
    event = current_event.event
    alert = "Seleccione un archivo para importar"
    redirect_to(admins_event_tickets_path(event), alert: alert) && return unless params[:file]
    lines = params[:file][:data].tempfile.map { |line| line.split(",") }
    lines.delete_at(0)

    lines.each do |tt_name, tt_code, c_name, barcode, f_name, l_name, mail|
      com = Company.find_by("LOWER(name) = ?", c_name.downcase) || Company.create!(name: c_name)
      agree = com.company_event_agreements.find_or_create_by!(event: event, aasm_state: "granted")

      type_params = { name: tt_name, company_code: tt_code, company_event_agreement: agree }
      ticket_type = event.company_ticket_types.find_or_create_by!(type_params)

      ticket_params = { code: barcode, company_ticket_type: ticket_type, event: event }
      ticket = Ticket.find_or_create_by!(ticket_params)

      p_params = { first_name: f_name, last_name: l_name, email: mail&.strip, credentiable: ticket }
      Purchaser.find_or_create_by!(p_params)
    end

    redirect_to(admins_event_tickets_path(event), notice: "Tickets imported")
  end

  def ban
    ticket = @fetcher.tickets.find(params[:id])
    ticket.update(banned: true)
    # station = current_event.stations
    #                        .joins(:station_type)
    #                        .find_by(station_types: { name: "customer_portal" })
    # atts = {
    #   event_id: current_event.id,
    #   station_id: station.id,
    #   transaction_category: "ban",
    #   transaction_origin: "customer_portal",
    #   transaction_type: "ban_ticket",
    #   banneable_id: ticket.id,
    #   banneable_type: "Ticket",
    #   reason: "",
    #   status_code: 0,
    #   status_message: "OK"
    # }
    # Operations::Base.new.portal_write(atts)
    redirect_to(admins_event_tickets_url)
  end

  def unban
    ticket = @fetcher.tickets.find(params[:id])

    if ticket.assigned_profile&.banned?
      flash[:error] = "Assigned profile is banned, unban it or unassign the ticket first"
    else
      ticket.update(banned: false)
      # station = current_event.stations
      #                        .joins(:station_type)
      #                        .find_by(station_types: { name: "customer_portal" })
      # atts = {
      #   event_id: current_event.id,
      #   station_id: station.id,
      #   transaction_category: "ban",
      #   transaction_origin: "customer_portal",
      #   transaction_type: "unban_ticket",
      #   banneable_id: ticket.id,
      #   banneable_type: "Ticket",
      #   reason: "",
      #   status_code: 0,
      #   status_message: "OK"
      # }
      # Operations::Base.perform_later(atts)
    end
    redirect_to(admins_event_tickets_url)
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Ticket".constantize.model_name,
      fetcher: @fetcher.tickets,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [
        :assigned_profile,
        assigned_ticket_credential: [profile: [:customer, active_gtag_assignment: :credentiable]]
      ],
      context: view_context
    )
  end

  def permitted_params
    params.require(:ticket).permit(
      :event_id,
      :code,
      :company_ticket_type_id,
      :credential_redeemed,
      :banned,
      purchaser_attributes: [:id, :first_name, :last_name, :email]
    )
  end
end
