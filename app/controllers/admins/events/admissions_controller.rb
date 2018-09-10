module Admins
  module Events
    class AdmissionsController < Admins::Events::BaseController
      def index
        @q = params[:q] ? @current_event.customers.ransack(params[:q]) : Customer.ransack({})
        @admissions = params[:q] ? Admission.search(@current_event, params[:q][:email_cont]) : []

        to_auth = @admissions.any? ? @admissions.first.class.where(event: @current_event, id: @admissions.first.id) : @current_event.customers.none
        authorize(to_auth, :index?)
        redirect_to([:admins, @current_event, @admissions.first]) if @admissions.size == 1
      end

      def merge
        @admission = Admission.find(@current_event, params[:id], params[:type])
        authorize @admission
        @q = params[:q] ? @current_event.customers.ransack(params[:q]) : Customer.ransack({})
        @admissions = params[:q] ? Admission.all(@current_event, @admission, params[:q][:email_cont]) : []

        to_auth = @admissions.any? ? @admissions.first.class.where(event: @current_event, id: @admissions.first.id) : @current_event.customers.none
        authorize(to_auth, :index?)
      end
    end
  end
end
