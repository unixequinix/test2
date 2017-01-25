class Api::V1::CredentialAssignmentSerializer < ActiveModel::Serializer
  attributes :reference, :type

  def type
    object.class.name.downcase
  end
end
