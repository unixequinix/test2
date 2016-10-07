class Admins::Events::ClaimsController < Admins::Events::BaseController
  before_action :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html
      format.csv do
        send_data(Csv::CsvExporter.to_csv(Claim.selected_data(:completed, current_event)))
      end
    end
  end

  def search
    render :index
  end

  def show
    @claim = current_event.claims.includes(claim_parameters: :parameter).find(params[:id])
  end

  def update
    @claim = current_event.claims.find(params[:id])
    profile = @claim.profile
    if @claim.update(permitted_params)
      redirect_to admins_event_profile_url(current_event, profile),
                  notice: I18n.t("alerts.updated")
    else
      redirect_to admins_event_profile_url(current_event, profile),
                  error: @claim.errors.full_messages.join(". ")
    end
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Claim".constantize.model_name,
      fetcher: current_event.claims,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:profile,
                              profile: :customer]
    )
  end

  def permitted_params
    params.require(:claim).permit(:aasm_state)
  end
end
