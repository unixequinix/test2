class Api::V1::ParameterSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :value

  def name
    object.parameter.name
  end
end
