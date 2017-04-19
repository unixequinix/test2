require "spec_helper"

RSpec.describe DeviceTransaction, type: :model do
  %w[event_id action device_uid device_db_index device_created_at initialization_type].each do |field|
    it "includes #{field} as mandatory" do
      expect(DeviceTransaction.mandatory_fields).to include(field)
    end
  end
end
