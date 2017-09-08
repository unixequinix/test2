module Requests
  module JsonHelpers
    def json
      JSON.parse(response.body)
    end

    def obj_to_json(obj, serializer)
      Json.parse(serializer.new(obj))
    end
  end
end
