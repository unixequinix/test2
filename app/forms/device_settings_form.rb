class DeviceSettingsForm
  include ActiveModel::Model
  include Virtus.model

  attribute :min_version_apk, String
  attribute :private_zone_password, String
  attribute :fast_removal_password, String
  attribute :uid_reverse, String
  attribute :touchpoint_update_online_orders, String
  attribute :pos_update_online_orders, String
  attribute :topup_initialize_gtag, String
  attribute :autotopup_enabled, String
  attribute :cypher_enabled, String
  attribute :gtag_blacklist, String
  attribute :event_id, Integer

  validates_presence_of :min_version_apk
  validates_presence_of :private_zone_password
  validates_presence_of :touchpoint_update_online_orders
  validates_presence_of :pos_update_online_orders
  validates_presence_of :topup_initialize_gtag
  validates_presence_of :private_zone_password
  validates_presence_of :fast_removal_password
  validates_presence_of :cypher_enabled
  validates_presence_of :autotopup_enabled
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
    Parameter.where(category: "device", group: "general").each do |parameter|
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.update(value: attributes[parameter.name.to_sym])
    end
  end
end
