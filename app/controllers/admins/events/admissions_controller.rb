module Admins
  module Events
    class AdmissionsController < Admins::Events::BaseController
      def index
        @q = params[:q] ? @current_event.customers.ransack(params[:q]) : Customer.ransack({})
        @admissions = params[:q] ? Admission.search(@current_event, params[:q][:email_cont]) : []
        authorize(:admissions, :index?)
      end
    end
  end
end
