module Api
  module V1
    class PreeventProductSerializer < Api::V1::BaseSerializer
      attributes :id, :name, :credentials, :credits

      # TODO: Add credentials and credits
      def credentials
        [2, 5]
      end

      def credits
        20
      end
    end
  end
end
