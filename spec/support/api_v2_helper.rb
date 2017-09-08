module Api
  module V2Helper
    def obj_to_json(obj, serializer)
      klass = "Api::V2::#{serializer}".constantize
      JSON.parse(klass.new(obj).to_json)
    end
  end
end
