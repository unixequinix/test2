module Api::V2
  class Simple::CustomerSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :email, :anonymous
  end
end
