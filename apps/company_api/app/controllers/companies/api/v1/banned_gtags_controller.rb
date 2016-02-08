module Companies
  module Api
    module V1
      class BannedGtagsController < Companies::Api::V1::BaseController
        def index
          @banned_gtags = Gtag.banned
                              .search_by_company_and_event(current_company.name, current_event)

          render json: {
            event_id: current_event.id,
            blacklisted_gtags: @banned_gtags.map { |gtag| Companies::Api::V1::GtagSerializer.new(gtag) }
          }
        end

        def create
          @banned_gtag = BannedGtag.new(banned_gtag_params)

          assign = CredentialAssignment.find_by(credentiable_id: banned_gtag_params[:gtag_id],
                                                credentiable_type: "Gtag")

          BannedCustomerEventProfile.new(assign.customer_event_profile_id) unless assign.nil?

          if @banned_gtag.save
            render status: :created, json: @banned_gtag.gtag,
                                     serializer: Companies::Api::V1::GtagSerializer
          else
            render status: :bad_request,
                   json: { message: I18n.t("company_api.gtags.bad_request"),
                           errors: @banned_gtag.errors }
          end
        end

        def destroy
          @banned_gtag = BannedGtag.includes(:gtag)
                                   .find_by(gtags: { tag_uid: params[:id],
                                                     event_id: current_event.id })

          render(status: :not_found, json: :not_found) && return if @banned_gtag.nil?
          render(status: :internal_server_error, json: :internal_server_error) && return unless @banned_gtag.destroy
          render(status: :no_content, json: :no_content)
        end

        private

        def banned_gtag_params
          gtag_id = Gtag.select(:id).find_by(tag_uid: params[:gtags_blacklist][:tag_uid])
          params[:gtags_blacklist][:gtag_id] = gtag_id.id if gtag_id.present?
          params.require(:gtags_blacklist).permit(:gtag_id)
        end
      end
    end
  end
end
