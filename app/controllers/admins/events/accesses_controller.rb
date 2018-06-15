module Admins
  module Events
    class AccessesController < Admins::Events::BaseController
      before_action :set_access, except: %i[index new create]
      include AnalyticsHelper

      def index
        @accesses = @current_event.accesses.page(params[:page])
        authorize @accesses
      end

      def new
        @access = @current_event.accesses.new(mode: "permanent")
        authorize @access
      end

      def create
        @access = @current_event.accesses.new(permitted_params)
        authorize @access

        if @access.save
          flash[:notice] = t("alerts.created")
          redirect_to admins_event_accesses_path
        else
          flash.now[:alert] = t("alerts.error")
          render :new
        end
      end

      def update
        respond_to do |format|
          if @access.update(permitted_params)
            flash[:notice] = t("alerts.updated")
            format.html { redirect_to admins_event_accesses_path }
            format.json { render json: @access }
          else
            flash.now[:alert] = t("alerts.error")
            format.html { render :edit }
            format.json { render json: @access.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        respond_to do |format|
          if @access.destroy
            format.html { redirect_to admins_event_accesses_path, notice: t("alerts.destroyed") }
            format.json { render json: true }
          else
            format.html { redirect_to [:admins, @current_event, @access], alert: @access.errors.full_messages.to_sentence }
            format.json { render json: { errors: @access.errors }, status: :unprocessable_entity }
          end
        end
      end

      def capacity
        cols = ['Date Time', 'Direction', 'Access', 'Capacity']
        access_in_out = prepare_pokes(cols, pokes_access_in_out(@access))
        access_capacity = prepare_pokes(cols, pokes_access_capacity(@access))

        @views =
          { chart_id: "in_out_", title: "In-Out by Hour", cols: ["Direction"], rows: ["Date Time"], data: access_in_out, metric: ["Access"], decimals: 0 },
          { chart_id: "capacity_", title: "Capacity by Hour", cols: ["Direction"], rows: ["Date Time"], data: access_capacity, metric: ["Capacity"], decimals: 0 }

        prepare_data params[:action], [['Direction'], ['Date Time'], ['Access'], 0]
      end

      def ticket_type
        cols = ['Date Time', 'Ticket Type', 'Staff', 'Catalog Item', 'Check In', 'Access', 'Zone', 'Location', 'Station Type', 'Station Name']
        access_by_ticket_type = prepare_pokes(cols, pokes_access_by_ticket_type(@access))
        @views = { chart_id: "access_ticket_type", title: "Unique Access by Ticket Type", cols: ["Ticket Type"], rows: ["Date Time"], data: access_by_ticket_type, metric: ["Access"], decimals: 0 }
        prepare_data params[:action], [['Direction'], ['Date Time'], ['Access'], 0]
      end

      private

      def set_access
        @access = @current_event.accesses.find(params[:id])
        authorize @access
      end

      def permitted_params
        params.require(:access).permit(:name, :mode)
      end

      def prepare_data(name, _array)
        @name = name
        respond_to do |format|
          format.js { render action: :load_report }
        end
      end
    end
  end
end
