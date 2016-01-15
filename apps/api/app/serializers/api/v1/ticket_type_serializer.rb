module Api
  module V1
    class TicketTypeSerializer < Api::V1::BaseSerializer
      attributes :name, :simplified_name, :company, :credit, :entitlements

      def entitlements
        object.entitlements.map(&:name).join(', ')
      end
    end
  end
end
