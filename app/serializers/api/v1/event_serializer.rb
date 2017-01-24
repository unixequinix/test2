class Api::V1::EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :staging_start, :staging_end

  def staging_start
    object.start_date - 7.days
  end

  def staging_end
    object.end_date + 7.days
  end
end
