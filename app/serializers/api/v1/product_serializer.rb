class Api::V1::ProductSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :description, :is_alcohol
end
