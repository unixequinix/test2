module Api
  module V1
    class EventSerializer < Api::V1::BaseSerializer
      attributes :id, :name, :description, :start_date, :end_date
    end
  end
end
