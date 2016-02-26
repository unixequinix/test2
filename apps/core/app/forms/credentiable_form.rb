class CredentiableForm
  include ActiveModel::Model
  include Virtus.model

  attribute :name, String
  attribute :description, String
  attribute :step, Integer
  attribute :initial_amount, Integer
  attribute :max_purchasable, Integer
  attribute :min_purchasable, Integer
  attribute :create_credential_type, Boolean, default: false
  attribute :event_id, Integer

  validates_presence_of :name
  validates_presence_of :step
  validates_presence_of :initial_amount
  validates_presence_of :max_purchasable
  validates_presence_of :min_purchasable
  validates_presence_of :event_id
end
