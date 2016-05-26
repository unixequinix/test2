# rubocop:disable Metrics/ClassLength
class Admins::Events::GtagsController < Admins::Events::CheckinBaseController
  before_filter :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html
      format.csv { send_data(Csv::CsvExporter.to_csv(Gtag.selected_data(current_event.id))) }
    end
  end

  def search
    render :index
  end

  def show
    @gtag = @fetcher.gtags.includes(credential_assignments: { profile: :customer })
                    .find(params[:id])
  end

  def new
    @gtag = Gtag.new
    @gtag.build_purchaser
  end

  def create
    @gtag = Gtag.new(permitted_params)
    if @gtag.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_gtags_url
    else
      flash.now[:error] = @gtag.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @gtag = @fetcher.gtags.find(params[:id])
  end

  def update
    @gtag = @fetcher.gtags.find(params[:id])
    if @gtag.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_gtag_url(current_event, @gtag)
    else
      flash.now[:error] = @gtag.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @gtag = @fetcher.gtags.find(params[:id])
    if @gtag.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
    end
    redirect_to admins_event_gtags_url
  end

  def destroy_multiple
    gtags = params[:gtags]
    if gtags
      @fetcher.gtags.where(id: gtags.keys).each do |gtag|
        flash[:error] = gtag.errors.full_messages.join(". ") unless gtag.destroy
      end
    end
    redirect_to admins_event_gtags_url
  end

  def ban
    gtag = @fetcher.gtags.find(params[:id])
    gtag.update!(banned: true)
    write_transaction("ban", gtag)
    redirect_to(admins_event_gtags_url)
  end

  def unban
    gtag = @fetcher.gtags.find(params[:id])

    if gtag.assigned_profile&.banned?
      flash[:error] = "Assigned profile is banned, unban it or unassign the gtag first"
    else
      gtag.update(banned: false)
      write_transaction("unban", gtag)
    end
    redirect_to(admins_event_gtags_url)
  end

  private

  def write_transaction(action, gtag)
    station = current_event.stations
                           .joins(:station_type)
                           .find_by(station_types: { name: "customer_portal" })
    Operations::Base.new.portal_write(event_id: current_event.id,
                                      station_id: station.id,
                                      transaction_category: "ban",
                                      transaction_origin: "customer_portal",
                                      transaction_type: "#{action}_gtag",
                                      banneable_id: gtag.id,
                                      banneable_type: "Gtag",
                                      reason: "",
                                      status_code: 0,
                                      status_message: "OK")
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Gtag".constantize.model_name,
      fetcher: @fetcher.gtags,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [
        :assigned_profile,
        assigned_gtag_credential: [profile: [:customer, active_tickets_assignment: :credentiable]]],
      context: view_context
    )
  end

  def permitted_params
    params.require(:gtag).permit(
      :event_id,
      :tag_uid,
      :credential_redeemed,
      :banned,
      :company_ticket_type_id,
      purchaser_attributes: [:id, :first_name, :last_name, :email, :gtag_delivery_address])
  end
end
