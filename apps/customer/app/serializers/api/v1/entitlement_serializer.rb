module Api
  module V1
    class EntitlementSerializer < Api::V1::BaseSerializer
      attributes :name, :company, :credit

      def entitlements
        object.entitlements.map do |entitlement|
          entitlement.name
        end.join(', ')
      end
    end
  end
end
