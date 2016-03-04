class Api::V1::CredentialTypeSerializer < Api::V1::BaseSerializer
  attributes :id, :position, :catalogable_id, :catalogable_type

  def catalogable_id
    object.catalog_item.catalogable_id
  end

  def catalogable_type
    object.catalog_item.catalogable_type
  end

  def position
    object.memory_position
  end
end
