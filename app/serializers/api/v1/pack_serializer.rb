class Api::V1::PackSerializer < ActiveModel::Serializer
  attributes :id, :name, :accesses, :credits, :user_flags

  def accesses
    object.catalog_items.accesses.select(:id, :amount).map(&:attributes)
  end

  def credits
    object.catalog_items.credits.sum(:amount)
  end

  def user_flags
    object.catalog_items.user_flags.pluck(:id)
  end
end
