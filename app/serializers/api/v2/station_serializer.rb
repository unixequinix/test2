module Api::V2
  class StationSerializer < ActiveModel::Serializer
    attributes :id, :name, :group, :location, :category, :reporting_category, :address, :registration_num, :official_name, :hidden

    has_many :products, serializer: ProductSerializer
  end
end
