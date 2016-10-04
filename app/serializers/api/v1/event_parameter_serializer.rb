class Api::V1::EventParameterSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :value

  def name
    object.parameter.name
  end
end
