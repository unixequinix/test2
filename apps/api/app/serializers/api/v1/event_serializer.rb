class Api::V1::EventSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :description, :start_date, :end_date
end
