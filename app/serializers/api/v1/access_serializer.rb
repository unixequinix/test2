class Api::V1::AccessSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :mode, :position, :memory_length

  delegate :name, to: :object

  delegate :mode, to: :object

  def position
    object.memory_position
  end

  def memory_length
    object.memory_length.to_i
  end
end
