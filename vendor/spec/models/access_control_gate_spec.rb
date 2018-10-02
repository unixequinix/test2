require "rails_helper"

RSpec.describe AccessControlGate, type: :model do
  subject { build(:access_control_gate, access: create(:access)) }

  describe "station touch" do
    before(:each) { subject.save }

    it "resets the station updated_at field" do
      expect { subject.update!(direction: "X") }.to change(subject.station, :updated_at)
    end
  end
end
