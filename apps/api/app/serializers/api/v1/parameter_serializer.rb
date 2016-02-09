module Api
  module V1
    class ParameterSerializer < Api::V1::BaseSerializer
      attributes :id, :name, :value

      def name
        object.parameter.name
      end
    end
  end
end
