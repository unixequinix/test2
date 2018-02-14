module Admins
  module Events
    class CompaniesController < Admins::Events::BaseController
      before_action :set_company, except: %i[index new create]

      def index
        @q = @current_event.companies.order(:name).ransack(params[:q])
        @companies = @q.result
        authorize @companies
        @companies = @companies.page(params[:page])
      end

      def new
        @company = @current_event.companies.new(hidden: true)
        @company.generate_access_token
        authorize @company
      end

      def create
        @company = @current_event.companies.new(permitted_params)
        authorize @company
        if @company.save
          redirect_to admins_event_companies_path, notice: t("alerts.created")
        else
          flash.now[:alert] = t("alerts.error")
          render :new
        end
      end

      def update
        respond_to do |format|
          if @company.update(permitted_params)
            format.html { redirect_to admins_event_companies_path, notice: t("alerts.updated") }
            format.json { render json: @company }
          else
            flash.now[:alert] = t("alerts.error")
            format.html { render :edit }
            format.json { render json: @company.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        if @company.destroy
          redirect_to admins_event_companies_path, notice: t("alerts.destroyed")
        else
          flash.now[:alert] = t("errors.messages.ticket_type_dependent")
          @companies = @current_event.companies.page
          render :index
        end
      end

      private

      def set_company
        @company = @current_event.companies.find(params[:id])
        authorize @company
      end

      def permitted_params
        params.require(:company).permit(:name, :access_token, :hidden)
      end
    end
  end
end
