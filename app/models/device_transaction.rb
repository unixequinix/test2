class DeviceTransaction < ActiveRecord::Base
  belongs_to :event

  def self.mandatory_fields
    %w(event_id action device_uid device_db_index device_created_at initialization_type)
  end
end
