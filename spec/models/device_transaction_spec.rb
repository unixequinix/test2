# == Schema Information
#
# Table name: device_transactions
#
#  action                  :string
#  created_at              :datetime
#  device_created_at       :string
#  device_created_at_fixed :string
#  device_db_index         :integer
#  initialization_type     :string
#  number_of_transactions  :integer
#  updated_at              :datetime
#
# Indexes
#
#  index_device_transactions_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_d4bd5146d8  (event_id => events.id)
#

require "spec_helper"

RSpec.describe DeviceTransaction, type: :model do
  %w(event_id action device_uid device_db_index device_created_at initialization_type).each do |field|
    it "includes #{field} as mandatory" do
      expect(DeviceTransaction.mandatory_fields).to include(field)
    end
  end
end
