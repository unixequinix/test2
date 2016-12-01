class Api::V1::BaseSerializer < ActiveModel::Serializer
  # Removes the nil attributes to reduce the response size
  def attributes(_atts)
    super.compact
  end
end
