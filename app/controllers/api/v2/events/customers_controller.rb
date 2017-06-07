class Api::V2::Events::CustomersController < Api::V2::BaseController
  before_action :set_customer, only: %i[refunds transactions show update destroy]

  # GET /customers
  def index
    @customers = @current_event.customers
    authorize @customers

    render json: @customers, each_serializer: Api::V2::Simple::CustomerSerializer
  end

  # GET /customers/:id/refunds
  def refunds
    @refunds = @customer.refunds
    render json: @refunds, each_serializer: Api::V2::RefundSerializer
  end

  # GET /customers/:id/transactions
  def transactions
    gtag = @customer.active_gtag
    @transactions = gtag ?  gtag.transactions.credit.status_ok.order(:gtag_counter) : []
    render json: @transactions, each_serializer: Api::V2::TransactionSerializer
  end

  # GET /customers/1
  def show
    render json: @customer, serializer: Api::V2::Full::CustomerSerializer
  end

  # POST /customers
  def create
    @customer = @current_event.customers.new(customer_params)
    authorize @customer

    if @customer.save
      render json: @customer, serializer: Api::V2::Full::CustomerSerializer, status: :created, location: [:admins, @current_event, @customer]
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /customers/1
  def update
    if @customer.update(customer_params)
      render json: @customer, serializer: Api::V2::Full::CustomerSerializer
    else
      render json: @customer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /customers/1
  def destroy
    @customer.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_customer
    @customer = @current_event.customers.find_by(id: params[:id]) || @current_event.customers.find_by(email: params[:id])
    authorize @customer
  end

  # Only allow a trusted parameter "white list" through.
  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :email, :phone, :birthdate, :phone, :postcode, :address, :city, :country, :gender, :password, :password_confirmation, :agreed_on_registration) # rubocop:disable Metrics/LineLength
  end
end
