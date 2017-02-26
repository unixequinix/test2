require "spec_helper"

RSpec.describe OperatorTransaction, type: :model do
  subject { OperatorTransaction }

  describe ".mandatory_fields" do
    it "returns the correct fields" do
      expect(subject.mandatory_fields).to include("operator_value")
      expect(subject.mandatory_fields).to include("operator_station_id")
    end
  end
end
