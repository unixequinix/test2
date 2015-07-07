class Admins::ClaimsController < Admins::BaseController

  def index
    @q = Claim.search(params[:q])
    @claims = @q.result(distinct: true).page(params[:page]).includes(:customer)
  end

  def search
    index
    render :index
  end

  def show
    @claim = Claim.includes(claim_parameters: :parameter).find(params[:id])
  end

end
