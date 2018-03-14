module Admins
  module Events
    class AdmissionsController < Admins::Events::BaseController
      before_action :set_admission, only: %i[merge]

      def index
        @q = params[:q] ? @current_event.customers.ransack(params[:q]) : Customer.ransack({})
        @admissions = params[:q] ? Admission.search(@current_event, params[:q][:email_cont]) : []
        authorize(:admissions, :index?)
      end

      def merge
        @q = params[:q] ? @current_event.customers.ransack(params[:q]) : Customer.ransack({})
        @admissions = params[:q] ? Admission.all(@current_event, @admission, params[:q][:email_cont]) : []
        authorize(:admissions, :merge?)
      end

      private

      def set_admission
        @admission = Admission.find(@current_event, params[:id], params[:type])
        authorize @admission
      end
    end
  end
end
