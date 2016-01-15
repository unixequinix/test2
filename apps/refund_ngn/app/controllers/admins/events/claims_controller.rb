class Admins::Events::ClaimsController < Admins::Events::RefundsBaseController
  before_filter :set_presenter, only: [:index, :search]

  def index
    respond_to do |format|
      format.html
      format.csv { send_data(Csv::CsvExporter.to_csv(Claim.selected_data(:completed, current_event))) }
    end
  end

  def search
    render :index
  end

  def show
    @claim = @fetcher.claims.includes(claim_parameters: :parameter).find(params[:id])
  end

  def update
    @claim = @fetcher.claims.find(params[:id])
    if @claim.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_event_customer_url(current_event, @claim.customer_event_profile.customer)
    else
      flash[:error] = @claim.errors.full_messages.join('. ')
      redirect_to admins_event_customer_event_profile_url(current_event, @claim.customer_event_profile.customer)
    end
  end

  private

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: 'Claim'.constantize.model_name,
      fetcher: @fetcher.claims,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:customer_event_profile,
                              customer_event_profile: :customer]
    )
  end

  def permitted_params
    params.require(:claim).permit(:aasm_state)
  end
end
