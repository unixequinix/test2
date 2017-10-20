module Companies
  class GtagSerializer < ActiveModel::Serializer
    attributes :id, :tag_uid
  end
end
