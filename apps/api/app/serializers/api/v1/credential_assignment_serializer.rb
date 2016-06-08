class Api::V1::CredentialAssignmentSerializer < Api::V1::BaseSerializer
  attributes :reference, :type

  def reference
    if object.credentiable_type == "Ticket"
      object.credentiable.code
    else
      object.credentiable.tag_uid
    end
  end

  def type
    object.credentiable_type.downcase
  end
end
