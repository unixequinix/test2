class Admins::Events::RefundsController < Admins::Events::BaseController
  before_action :set_refund, only: %i[show destroy update]

  def index
    @refunds = @current_event.refunds.includes(:customer).page(params[:page])
    authorize @refunds

    @graph = %w[started completed].map do |action|
      data = @current_event.refunds.where(status: action).group_by_day(:created_at).sum(:amount)
      data = data.collect { |k, v| [k, v.to_i.abs] }
      { name: action, data: Hash[data] }
    end

    respond_to do |format|
      format.html
      format.csv { send_data(CsvExporter.to_csv(Refund.query_for_csv(@current_event))) }
    end
  end

  def update
    respond_to do |format|
      if @refund.update(permitted_params)
        format.html { redirect_to [:admins, @current_event, @refund], notice: t("alerts.updated") }
        format.json { render status: :ok, json: @refund }
      else
        format.html { render :edit }
        format.json { render json: { errors: @refund.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    message = @refund.destroy ? { notice: t('alerts.destroyed') } : { alert: @refund.errors.full_messages.join(",") }
    redirect_to request.referer, message
  end

  private

  def set_refund
    @refund = @current_event.refunds.find(params[:id])
    authorize @refund
  end

  def permitted_params
    params.require(:refund).permit(:state, :field_a, :field_b)
  end
end
