class Api::V2::StationSerializer < ActiveModel::Serializer
  attributes :id, :name, :group, :location, :category, :reporting_category, :address, :registration_num, :official_name, :hidden
end
