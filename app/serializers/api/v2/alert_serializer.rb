class AlertSerializer < ActiveModel::Serializer
  attributes :id, :body, :event_id, :subject_id, :subject_type
end
