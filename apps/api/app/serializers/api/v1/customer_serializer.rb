class Api::V1::CustomerSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :name, :surname
end
