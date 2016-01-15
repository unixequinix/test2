module Api
  module V1
    class EntitlementSerializer < Api::V1::BaseSerializer
      attributes :name, :company, :credit

      def entitlements
        object.entitlements.map(&:name).join(', ')
      end
    end
  end
end
