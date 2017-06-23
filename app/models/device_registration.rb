class DeviceRegistration < ApplicationRecord
  belongs_to :device
  belongs_to :event

  attr_accessor :operator, :station, :last_time_used

  def name
    device.asset_tracker.present? ? device.asset_tracker : device.mac
  end

  # rubocop:disable Metrics/LineLength, Rails/TimeZone
  def resolve_time!(start_date = event.start_date.to_formatted_s(:transactions), end_date = event.end_date.to_formatted_s(:transactions), actions = %w[sale sale_refund])
    device_ts = event.transactions.where(device_uid: device.mac).order(:device_db_index)
    bad_ids = device_ts.onsite.where(action: actions).where.not(device_created_at: (start_date..end_date)).pluck(:id)
    diff = nil

    device_ts.each.with_index do |bad_t, index|
      if bad_ids.include?(bad_t.id)
        last_good = index.zero? ? device_ts[index] : device_ts[index - 1]
        bad_t.update!(device_created_at: start_date) && next if bad_t == last_good

        good_date = Time.parse(last_good.device_created_at)
        bad_date = Time.parse(bad_t.device_created_at)

        diff = (good_date - bad_date) if diff.nil?

        bad_t.update!(device_created_at: (bad_date + diff + 60).to_formatted_s(:transactions))
        bad_ids.delete(bad_t.id)
      else
        diff = nil
      end
    end
  end

  # TODO: refactor into 2 methods
  def status
    last_onsite = event.transactions.onsite.where(device_uid: device.mac).order(:device_created_at).last
    self.operator = last_onsite&.operator_tag_uid
    self.station = last_onsite&.station&.name
    self.last_time_used = last_onsite&.device_created_at

    case
      when (server_transactions != number_of_transactions) then "to_check"
      when action.in?(%w[pack_device lock_device]) then "locked"
      when server_transactions.zero? && number_of_transactions.zero? then "staged"
      when action.eql?("device_initialization") then "live"
      else "no_idea"
    end
  end
end
