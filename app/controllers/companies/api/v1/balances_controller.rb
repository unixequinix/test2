class Companies::Api::V1::BalancesController < Companies::Api::V1::BaseController
  def show
    @gtag = @current_event.gtags.includes(:customer).find_by(tag_uid: params[:id])

    if @gtag
      render json: @gtag, serializer: Companies::Api::V1::BalanceSerializer
    else
      render(status: :not_found,
             json: { status: "not_found", error: "Gtag with id #{params[:id]} not found." })
    end
  end
end
