class Admins::Events::PaymentGatewaysController < Admins::Events::BaseController
  before_action :set_gateway, only: [:edit, :update, :destroy, :topup, :refund]
  before_action :set_attributes, only: [:new, :edit, :update]

  def index
    @gateways = current_event.payment_gateways
  end

  def new
    @gateway = current_event.payment_gateways.new(gateway: params[:gateway], data: {})
  end

  def create
    @gateway = current_event.payment_gateways.new(gateway: permitted_params[:gateway], data: permitted_params[:data])
    if @gateway.save
      redirect_to admins_event_payment_gateways_path(current_event)
    else
      @attributes = set_attributes
      flash.now[:error] = @gateway.errors.full_messages.to_sentence
      render :new, gateway: permitted_params[:gateway]
    end
  end

  def update
    if @gateway.update(permitted_params)
      redirect_to admins_event_payment_gateways_path(current_event)
    else
      flash.now[:error] = @gateway.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    @gateway.destroy
    redirect_to admins_event_payment_gateways_path(current_event)
  end

  def topup
    @gateway.update(topup: !@gateway.topup?)
    redirect_to admins_event_payment_gateways_path(current_event)
  end

  def refund
    @gateway.update(refund: !@gateway.refund?)
    redirect_to admins_event_payment_gateways_path(current_event)
  end

  private

  def set_gateway
    @gateway = current_event.payment_gateways.find(params[:id])
  end

  def set_attributes
    gateway = @gateway&.gateway || params[:gateway]
    settings = PaymentGateway::GATEWAYS[gateway]
    @config_atts = settings["config"]
    @refund_atts = settings["refund"]
  end

  def permitted_params
    params.require(:payment_gateway)
          .permit(:gateway, data: [:login, :password, :secret_key, :client_id, :signature, :terminal, :currency, :destination, :fee, :minimum]) # rubocop:disable Metrics/LineLength
  end
end
