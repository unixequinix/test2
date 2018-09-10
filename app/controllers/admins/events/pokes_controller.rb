module Admins
  module Events
    class PokesController < Admins::Events::BaseController
      before_action :set_poke, only: %i[status_9 status_0]

      def status_9
        @poke.update(status_code: 9)
        @poke.operation&.update(status_code: 9, status_message: "cancelled by user #{current_user.email}")
        @poke.customer_gtag&.recalculate_all
        return_url = request.referer || admins_event_poke_path(@current_event, @poke, type: @poke.category)
        redirect_to(return_url, notice: "poke cancelled successfully")
      end

      def status_0
        @poke.update(status_code: 0)
        @poke.operation&.update(status_code: 0, status_message: "accepted by user #{current_user.email}")
        @poke.customer_gtag&.recalculate_all
        return_url = request.referer || admins_event_poke_path(@current_event, @poke, type: @poke.category)
        redirect_to(return_url, notice: "poke accepted successfully")
      end

      private

      def set_poke
        @poke = @current_event.pokes.find(params[:id])
        authorize @poke
      end
    end
  end
end
