module Api
  module V1
    class TicketTypeSerializer < Api::V1::BaseSerializer
      attributes :name, :company, :credit, :entitlements

      def entitlements
        object.entitlements.map do |entitlement|
          entitlement.name
        end.join(', ')
      end
    end
  end
end
