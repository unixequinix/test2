class Api::V1::CredentialAssignmentSerializer < Api::V1::BaseSerializer
  attributes :reference, :type

  def reference
    object.reference.to_s
  end

  def type
    object.class.name.downcase
  end
end
