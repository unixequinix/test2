module Api::V2
  class Events::PokesController < BaseController
    # GET api/v2/events/:event_id/pokes
    # GET api/v2/events/:event_id/customers/:customer_id/pokes
    # GET api/v2/events/:event_id/gtags/:gtag_id/pokes
    # GET api/v2/events/:event_id/devices/:device_id/pokes
    def index
      key, id = params.permit!.select { |k, _v| k.to_s.include?("_id") }.reject { |k, _v| k.to_s == "event_id" }.to_h.to_a.first
      klass = key.to_s.gsub("_id", "")

      @pokes = Admission.find(@current_event, id, klass).pokes
      authorize @pokes

      paginate json: @pokes, each_serializer: Api::V2::PokeSerializer
    end
  end
end
