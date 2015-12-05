class Admins::Events::ClaimsController < Admins::Events::RefundsBaseController
  def index
    @q = @fetcher.claims.search(params[:q])
    @claims = @q.result(distinct: true).page(params[:page]).includes(:customer_event_profile, customer_event_profile: :customer)
    @claims_count = @q.result(distinct: true).count
    respond_to do |format|
      format.html
      format.csv { send_data(Csv::CsvExporter.to_csv(Claim.selected_data(:completed, current_event)))}
    end
  end

  def search
    @q =  @fetcher.claims.search(params[:q])
    @claims = @q.result(distinct: true).page(params[:page]).includes(:customer_event_profile)
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
      flash[:error] = @claim.errors.full_messages.join(". ")
      redirect_to admins_event_customer_event_profile_url(current_event, @claim.customer_event_profile.customer)
    end
  end

  private
    def permitted_params
      params.require(:claim).permit(:aasm_state)
    end
end
