module Admins
  module Events
    class OperatorsController < Admins::Events::BaseController
      def index
        @q = params[:q] ? @current_event.customers.ransack(params[:q]) : Customer.ransack({})
        @operators = params[:q] ? Operator.search(@current_event, params[:q][:email_cont]) : []

        to_auth = @operators.any? ? @operators.first.class.where(event: @current_event, id: @operators.first.id) : @current_event.customers.none
        authorize(to_auth, :index?)
        redirect_to([:admins, @current_event, @operators.first]) if @operators.size == 1
      end

      def merge
        @operator = Operator.find(@current_event, params[:id], params[:type])
        authorize @operator
        @q = params[:q] ? @current_event.customers.ransack(params[:q]) : Customer.ransack({})
        @operators = params[:q] ? Operator.all(@current_event, @operator, params[:q][:email_cont]) : []

        to_auth = @operators.any? ? @operators.first.class.where(event: @current_event, id: @operators.first.id) : @current_event.customers.none
        authorize(to_auth, :index?)
      end
    end
  end
end
