module Api
  module V1
    class BannedTicketSerializer < Api::V1::BaseSerializer
      attributes :id, :reference

      def reference
        object.code
      end
    end
  end
end
