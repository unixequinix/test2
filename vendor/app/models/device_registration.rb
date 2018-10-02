class DeviceRegistration < ApplicationRecord
  belongs_to :device
  belongs_to :event

  attr_accessor :operator, :station, :last_time_used

  scope(:allowed, -> { where(allowed: true) })
  scope(:not_allowed, -> { where.not(allowed: true) })

  def name
    device.asset_tracker.presence || device.mac
  end

  def time_diff
    current_time.present? ? current_time - updated_at : 0
  end

  def status
    case
      when (server_transactions != number_of_transactions) && action != "device_initialization" then "to_check"
      when action.in?(%w[pack_device lock_device]) then "locked"
      when server_transactions.zero? && number_of_transactions.zero? && action.eql?("device_initialization") then "staged"
      when (!server_transactions.zero? || !number_of_transactions.zero?) && action.eql?("device_initialization") then "live"
      else "event_assigned"
    end
  end

  def load_last_results
    last_onsite = event.transactions.onsite.where(device: device).order(:device_created_at).last
    self.operator = last_onsite&.operator_tag_uid
    self.station = last_onsite&.station&.name
    self.last_time_used = last_onsite&.device_created_at
  end
end
