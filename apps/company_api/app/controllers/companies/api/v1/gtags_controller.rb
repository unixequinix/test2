class Companies::Api::V1::GtagsController < Companies::Api::V1::BaseController
  def index
    @gtags = Gtag.search_by_company_and_event(current_company.name, current_event)

    render json: {
      event_id: current_event.id,
      gtags: @gtags.map { |gtag| Companies::Api::V1::GtagSerializer.new(gtag) }
    }
  end

  def show
    @gtag = Gtag.search_by_company_and_event(current_company.name, current_event)
            .find_by(id: params[:id])

    if @gtag
      render json: @gtag
    else
      render status: :not_found,
             json: { error: I18n.t("company_api.gtags.not_found", gtag_id: params[:id]) }
    end
  end

  def create
    @gtag = Gtag.new(gtag_params)
    @gtag.event = current_event
    @gtag.build_purchaser(email: params[:gtag][:purchaser_email],
                          first_name: params[:gtag][:purchaser_first_name],
                          last_name: params[:gtag][:purchaser_last_name])

    if @gtag.save
      render status: :created, json: Companies::Api::V1::GtagSerializer.new(@gtag)
    else
      render status: :bad_request,
             json: { message: I18n.t("company_api.gtags.bad_request"),
                     errors: @gtag.errors }
    end
  end

  def update
    @gtag = Gtag.search_by_company_and_event(current_company.name, current_event)
            .find_by(id: params[:id])

    if @gtag.update(gtag_params) && update_purchaser(@gtag)
      render json: Companies::Api::V1::GtagSerializer.new(@gtag)
    else
      render status: :bad_request, json: { message: I18n.t("company_api.gtags.bad_request"),
                                           errors: @gtag.errors }
    end
  end

  private

  def gtag_params
    params[:gtag][:company_ticket_type_id] = params[:gtag][:ticket_type_id]
    params.require(:gtag).permit(:tag_serial_number, :tag_uid)
  end

  def update_purchaser(gtag)
    gtag.purchaser.update(email: params[:gtag][:purchaser_email],
                          first_name: params[:gtag][:purchaser_first_name],
                          last_name: params[:gtag][:purchaser_last_name])
  end
end
