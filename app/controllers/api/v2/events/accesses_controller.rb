class Api::V2::Events::AccessesController < Api::V2::BaseController
  before_action :set_access, only: %i[show update destroy]

  # GET /accesses
  def index
    @accesses = @current_event.accesses
    authorize @accesses

    render json: @accesses
  end

  # GET /accesses/1
  def show
    render json: @access
  end

  # POST /accesses
  def create
    @access = @current_event.accesses.new(access_params)
    authorize @accesse

    if @access.save
      render json: @access, status: :created, location: @access
    else
      render json: @access.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accesses/1
  def update
    if @access.update(access_params)
      render json: @access
    else
      render json: @access.errors, status: :unprocessable_entity
    end
  end

  # DELETE /accesses/1
  def destroy
    @access.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_access
    @access = @current_event.accesses.find(params[:id])
    authorize @accesse
  end

  # Only allow a trusted parameter "white list" through.
  def access_params
    params.require(:access).permit(:name, :mode)
  end
end
