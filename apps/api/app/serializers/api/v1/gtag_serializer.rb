module Api
  module V1
    class GtagSerializer < Api::V1::BaseSerializer
      attributes :id, :tag_uid, :tag_serial_number,
                 :credential_redeemed

      def attributes(*args)
        hash = super
        hash[:company_ticket_type_id] = object.company_ticket_type_id if
          object.company_ticket_type_id.present?
        hash[:customer_uid] = customer_uid if object.credential_assignments.first
        hash
      end

      def customer_uid
        object.credential_assignments.first.customer_event_profile_id
      end

      def reference
        object.code
      end
    end
  end
end
