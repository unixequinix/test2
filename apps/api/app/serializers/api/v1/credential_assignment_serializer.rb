class Api::V1::CredentialAssignmentSerializer < Api::V1::BaseSerializer
  attributes :id, :type

  def id
    object.credentiable_id
  end

  def type
    object.credentiable_type.downcase
    binding.pry
  end
end
