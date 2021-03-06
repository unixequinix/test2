module Admins
  module Events
    class RefundsController < Admins::Events::BaseController
      before_action :set_refund, except: %i[index]

      def index
        @q = @current_event.refunds.includes(:customer).ransack(params[:q])
        @refunds = @q.result

        @graph = %w[started completed].map do |action|
          data = @refunds.where(status: action).group_by_day("refunds.created_at").sum(:credit_base)
          data = data.collect { |k, v| [k, v.to_i.abs] }
          { name: action, data: Hash[data] }
        end

        @refunds = @refunds.page(params[:page])
        authorize @refunds

        respond_to do |format|
          format.html
          format.csv { send_data(CsvExporter.to_csv(@current_event.refunds.for_csv)) }
        end
      end

      def update
        respond_to do |format|
          if @refund.update(permitted_params)
            format.html { redirect_to [:admins, @current_event, @refund], notice: t("alerts.updated") }
            format.json { render status: :ok, json: @refund }
          else
            format.html { render :edit }
            format.json { render json: @refund.errors.to_json, status: :unprocessable_entity }
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
        params.require(:refund).permit(:state, fields: {})
      end
    end
  end
end
