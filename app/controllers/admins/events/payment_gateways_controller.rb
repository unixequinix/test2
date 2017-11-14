class Admins::Events::PaymentGatewaysController < Admins::Events::BaseController
  before_action :set_gateway, only: %i[edit update destroy topup refund]
  before_action :set_attributes, only: %i[new edit update]

  def index
    @gateways = @current_event.payment_gateways
    authorize @current_event.payment_gateways.new
  end

  def new
    @gateway = @current_event.payment_gateways.new(name: params[:name])
    authorize @gateway
  end

  def create
    @gateway = @current_event.payment_gateways.new(permitted_params)
    @gateway.data = permitted_params
    authorize @gateway
    if @gateway.save
      redirect_to admins_event_payment_gateways_path(@current_event), notice: t("alerts.created")
    else
      @attributes = set_attributes
      flash.now[:alert] = t("alerts.error")
      render :new, name: permitted_params[:name]
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
        format.json { render json: @gateway.errors.to_json, status: :unprocessable_entity }
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
    settings = PaymentGateway::GATEWAYS[name.to_sym]
    @config_atts = settings[:config]
  end

  def permitted_params
    params[:payment_gateway][:extra_fields] = params[:payment_gateway][:extra_fields] || (@gateway&.extra_fields || [])
    params[:payment_gateway][:fee] = params[:payment_gateway][:fee].to_f
    params[:payment_gateway][:minimum] = params[:payment_gateway][:minimum].to_f
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
                                            :refund,
                                            extra_fields: [])
  end
end
