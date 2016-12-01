# == Schema Information
#
# Table name: access_control_gates
#
#  direction  :string           not null
#
# Indexes
#
#  index_access_control_gates_on_access_id   (access_id)
#  index_access_control_gates_on_station_id  (station_id)
#
# Foreign Keys
#
#  fk_rails_1846655ccd  (station_id => stations.id)
#

require "spec_helper"

RSpec.describe AccessControlGate, type: :model do
  subject { build(:access_control_gate, access: create(:access)) }

  describe ".after_update" do
    before(:each) { subject.save }

    it "resets the station updated_at field" do
      expect { subject.update!(direction: "X") }.to change(subject.station, :updated_at)
    end
  end
end
