class AlertSerializer < ActiveModel::Serializer
  attributes :id, :body
  has_one :event
  has_one :subject
end
