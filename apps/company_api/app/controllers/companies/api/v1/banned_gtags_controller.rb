module Companies
  module Api
    module V1
      class BannedGtagsController < Companies::Api::V1::BaseController
        def index
          @banned_gtags = Gtag.banned.where(event: current_event)

          render json: {
            event_id: current_event.id,
            banned_gtags: @banned_gtags.map { |gtag| Companies::Api::V1::GtagSerializer.new(gtag) }
          }
        end

        def create
          @banned_gtag = BannedGtag.new(banned_gtag_params)

          cep_id = CredentialAssignment.find_by(credentiable_id: banned_gtag_params[:gtag_id],
                                                credentiable_type: "Gtag")
                                       .select(:customer_event_profile_id).customer_event_profile_id

          BannedCustomerEventProfile.new(cep_id) unless assignment.nil?

          if @banned_gtag.save
            render status: :created, json: @banned_gtag
          else
            render status: :bad_request,
                   json: { message: I18n.t("company_api.gtags.bad_request"),
                           errors: @banned_gtag.errors }
          end
        end

        def destroy
          @banned_gtag = BannedGtag.includes(:gtag)
                                   .find_by(gtags: { tag_uid: params[:id], event_id: current_event.id })

          render(status: :not_found, json: :not_found) && return if @banned_gtag.nil?
          render(status: :internal_server_error, json: :internal_server_error) && return unless @banned_gtag.destroy
          render(status: :no_content, json: :no_content)
        end

        private

        def banned_gtag_params
          gtag_id = Gtag.find_by(tag_uid: params[:banned_gtag][:tag_uid]).select(:id).id
          params[:banned_gtag][:gtag_id] = gtag_id
          params.require(:banned_gtag).permit(:gtag_id)
        end
      end
    end
  end
end
