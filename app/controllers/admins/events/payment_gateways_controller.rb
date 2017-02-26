class Admins::Events::PaymentGatewaysController < Admins::Events::BaseController
  before_action :set_gateway, only: [:edit, :update, :destroy, :topup, :refund]
  before_action :set_attributes, only: [:new, :edit, :update]

  def index
    @gateways = @current_event.payment_gateways
    authorize @gateways
  end

  def new
    @gateway = @current_event.payment_gateways.new(name: params[:name])
    authorize @gateway
  end

  def create
    # TODO: this is weird behaviour. But when mass assignment is done, a "string not matched" exception is show.
    #       believed to be something to do with serialization of hash stored attributes.
    @gateway = @current_event.payment_gateways.new(name: permitted_params.delete(:name))
    @gateway.data = permitted_params

    authorize @gateway
    if @gateway.save
      redirect_to admins_event_payment_gateways_path(@current_event), notice: t("alerts.created")
    else
      @attributes = set_attributes
      flash.now[:alert] = t("alerts.error")
      render :new, gateway: permitted_params[:gateway]
    end
  end

  def update
    respond_to do |format|
      if @gateway.update(permitted_params)
        format.html { redirect_to admins_event_payment_gateways_path(@current_event), notice: t("alerts.updated") }
        format.json { render json: @gateway }
      else
        flash.now[:alert] = t("alerts.error")
        format.html { render :edit }
        format.json { render json: { errors: @gateway.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @gateway.destroy
    redirect_to admins_event_payment_gateways_path(@current_event), notice: t("alerts.destroyed")
  end

  private

  def set_gateway
    @gateway = @current_event.payment_gateways.find(params[:id])
    authorize @gateway
  end

  def set_attributes
    name = @gateway&.name || params[:name]
    settings = PaymentGateway::GATEWAYS[name]
    @config_atts = settings["config"]
    @refund_atts = settings["refund"]
  end

  def permitted_params # rubocop:disable Metrics/MethodLength
    params.require(:payment_gateway).permit(:name,
                                            :refund_field_a_name,
                                            :refund_field_b_name,
                                            :fee,
                                            :minimum,
                                            :login,
                                            :password,
                                            :secret_key,
                                            :client_id,
                                            :client_secret,
                                            :public_key,
                                            :token,
                                            :signature,
                                            :terminal,
                                            :currency,
                                            :destination,
                                            :topup,
                                            :refund)
  end
end
