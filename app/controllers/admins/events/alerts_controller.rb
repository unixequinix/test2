module Admins
  module Events
    class Admins::Events::AlertsController < Admins::Events::BaseController
      before_action :set_alert, only: %i[update destroy]

      # GET /alerts
      # GET /alerts.json
      def index
        @resolved = params[:resolved].eql?("true") ? true : false
        @q = @current_event.alerts.includes(:subject).where(resolved: @resolved).order(priority: :desc, event_id: :asc, created_at: :desc).ransack(params[:q])
        @alerts = @q.result

        authorize(@alerts)
        @alerts = @alerts.group_by(&:priority)
      end

      # GET /alerts/read_all
      # GET /alerts/read_all.json
      def read_all
        @alerts = @current_event.alerts
        authorize(@alerts)
        @alerts.update_all(resolved: params[:resolved])

        respond_to do |format|
          format.html { redirect_to admins_event_alerts_path(@current_event, resolved: params[:resolved].!), notice: t("alerts.updated") }
          format.json { head :ok }
        end
      end

      # PATCH/PUT /alerts/:id
      # PATCH/PUT /alerts/:id.json
      def update
        respond_to do |format|
          if @alert.update(alert_params)
            format.html { redirect_to [:admins, @current_event, @alert], notice: t("alerts.updated") }
            format.json { render json: @alert, status: :ok, location: [:admins, @current_event, @alert] }
          else
            format.html { render :edit }
            format.json { render json: @alert.errors, status: :unprocessable_entity }
          end
        end
      end

      # DELETE /alerts/:id
      # DELETE /alerts/:id.json
      def destroy
        @alert.destroy
        respond_to do |format|
          format.html { redirect_to admins_event_alerts_path(@current_event), notice: t("alerts.destroyed") }
          format.json { head :no_content }
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_alert
        @alert = @current_event.alerts.find(params[:id])
        authorize(@alert)
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def alert_params
        params.require(:alert).permit(:resolved, :priority)
      end
    end
  end
end
