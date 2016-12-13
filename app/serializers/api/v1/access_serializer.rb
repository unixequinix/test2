class Api::V1::AccessSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :mode, :position, :memory_length

  delegate :name, to: :object

  def mode
    object.entitlement.mode
  end

  def position
    object.entitlement.memory_position
  end

  def memory_length
    object.entitlement.memory_length.to_i
  end
end
