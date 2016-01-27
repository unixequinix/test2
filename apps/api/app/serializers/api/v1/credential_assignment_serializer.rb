module Api
  module V1
    class CredentialAssignmentSerializer < Api::V1::BaseSerializer
      attributes :id, :type

      def id
        object.credentiable_id
      end

      def type
        object.credentiable_type
      end
    end
  end
end
