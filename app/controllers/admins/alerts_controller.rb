class Admins::AlertsController < Admins::BaseController
  before_action :set_alert, only: %i[update destroy]

  # GET /alerts
  # GET /alerts.json
  def index
    @resolved = params[:resolved].eql?("true") ? true : false
    @alerts = current_user.alerts.where(resolved: @resolved).order(priority: :desc, event_id: :desc).group_by(&:priority)
  end

  # POST /alerts
  # POST /alerts.json
  def create
    @alert = Alert.new(alert_params)

    respond_to do |format|
      if @alert.save
        format.html { redirect_to [:admins, @alert], notice: t("alerts.created") }
        format.json { render json: @alert, status: :created, location: [:admins, @alert] }
      else
        format.html { render :new }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alerts/1
  # PATCH/PUT /alerts/1.json
  def update
    respond_to do |format|
      if @alert.update(alert_params)
        format.html { redirect_to [:admins, @alert], notice: t("alerts.updated") }
        format.json { render json: @alert, status: :ok, location: [:admins, @alert] }
      else
        format.html { render :edit }
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alerts/1
  # DELETE /alerts/1.json
  def destroy
    @alert.destroy
    respond_to do |format|
      format.html { redirect_to admins_alerts_url, notice: t("alerts.destroyed") }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_alert
    @alert = Alert.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def alert_params
    params.require(:alert).permit(:event_id, :user_id, :subject_id, :subject_type, :body, :resolved, :priority)
  end
end
