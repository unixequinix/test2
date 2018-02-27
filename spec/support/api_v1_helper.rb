module Api
  module V1Helper
    def obj_to_json_v1(obj, serializer)
      klass = "Api::V1::#{serializer}".constantize
      JSON.parse(klass.new(obj).to_json)
    end
  end
end
