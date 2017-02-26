require "spec_helper"

RSpec.describe UserEngagementTransaction, type: :model do
  subject { UserEngagementTransaction }

  describe ".mandatory_fields" do
    it "returns the correct fields" do
      expect(subject.mandatory_fields).to include("message")
      expect(subject.mandatory_fields).to include("priority")
    end
  end
end
