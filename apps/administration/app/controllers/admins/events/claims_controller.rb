class Admins::Events::ClaimsController < Admins::Events::BaseController

  def index
    @q = @fetcher.claims.search(params[:q])
    @claims = @q.result(distinct: true).page(params[:page]).includes(:customer_event_profile, customer_event_profile: :customer)
    respond_to do |format|
      format.html
      format.csv { send_data(Csv::CsvExporter.to_csv(@fetcher.claims.selected_data(:completed, current_event)))}
    end
  end

  def search
    @q =  @fetcher.claims.search(params[:q])
    @claims = @q.result(distinct: true).page(params[:page]).includes(:customer_event_profile)
    render :index
  end

  def show
    #@claim = @fetcher.claims.includes(claim_parameters: :parameter).find(params[:id])
    @claim = Claim.includes(claim_parameters: :parameter).find(params[:id])
  end

  def update
    # @claim = @fetcher.claims.find(params[:id])
    @claim = Claim.find(params[:id])
    if @claim.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_event_customer_event_profile_url(current_event, @claim.customer_event_profile)
    else
      flash[:error] = @claim.errors.full_messages.join(". ")
      redirect_to admins_event_customer_event_profile_url(current_event, @claim.customer_event_profile)
    end
  end

  private

    def permitted_params
      params.require(:claim).permit(:aasm_state)
    end
end
