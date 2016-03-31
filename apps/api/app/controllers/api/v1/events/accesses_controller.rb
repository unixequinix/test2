class Api::V1::Events::AccessesController < Api::V1::Events::BaseController
  def index
    if request.headers["If-Modified-Since"]
      date = request.headers["If-Modified-Since"].to_time + 1
      accesses = @fetcher.accesses.where("accesses.updated_at > ?", date)
    else
      accesses = @fetcher.accesses
    end

    response.headers["Last-Modified"] = accesses.maximum(:updated_at).to_s
    render(json: accesses, each_serializer: Api::V1::AccessSerializer)
  end
end
