class DeviceSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :currency, String
  attribute :min_version_apk, String
  attribute :private_zone_password, String
  attribute :maximum_wb_balance, Integer
  attribute :uid_reverse, Boolean
  attribute :public_key_a, String
  attribute :event_id, Integer

  validates_presence_of :currency
  validates_presence_of :min_version_apk
  validates_presence_of :private_zone_password
  validates_presence_of :maximum_wb_balance
  validates_presence_of :public_key_a
  validates_presence_of :event_id


  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

  def persist!
    Parameter.where(category: "device").each do |parameter|
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end
