class Api::V1::ProductSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :is_alcohol

  def attributes(*args)
    hash = super
    hash[:description] = object.description if object.description
    hash
  end
end
