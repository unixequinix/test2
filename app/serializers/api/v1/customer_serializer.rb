class Api::V1::CustomerSerializer < Api::V1::BaseSerializer
  attributes :id, :email, :first_name, :last_name
end
