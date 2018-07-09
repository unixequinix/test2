module Admins
  module Events
    class ControlGatesController < Admins::Events::BaseController
      before_action do
        persist_query(%i[p q], true)
      end

      before_action :set_control_gates, only: :index

      def index
        @control_gates_in = @p.result
        @customers = @q.result

        authorize @control_gates_in
        @control_gates_in = @control_gates_in.page(params[:customersin])
        @customers = @customers.page(params[:customersout])

        respond_to do |format|
          format.html
        end
      end

      private

      def set_control_gates
        @access_transactions = @current_event.transactions.where(action: 'access_checkpoint', direction: -1).order('device_created_at DESC').to_a.uniq(&:customer_id)
        access_transactions_ids = @access_transactions.pluck(:id)
        access_transactions_customer_ids = @access_transactions.pluck(:customer_id)

        @p = @current_event.transactions.where(id: access_transactions_ids).includes(:customer, :station).ransack(params[:p])
        @q = @current_event.customers.where(id: (@current_event.customers.pluck(:id) - access_transactions_customer_ids)).ransack(params[:q])

        @control_gates_in = @p.result.page(params[:customersin])
        @control_gates_out = @q.result.page(params[:customersout])
      end

      def persist_query(cookie_keys, clear = false) # rubocop:disable  Metrics/PerceivedComplexity
        cookie_keys.map { |key| cookies.delete(key) } && return if clear

        param = :p if cookie_keys.include?(:p)
        param = :q if cookie_keys.include?(:q)

        cookies[param] = params[param].to_json if params[param]
        params[param].presence || (cookies[param].present? && JSON.parse(cookies[param]))
      end
    end
  end
end
