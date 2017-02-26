require "spec_helper"

RSpec.describe AccessTransaction, type: :model do
  subject { AccessTransaction }
  let(:access_transaction) { build(:access_transaction) }

  it "has a valid factory" do
    expect(access_transaction).to be_valid
  end

  describe ".mandatory_fields" do
    it "returns the correct fields" do
      expect(subject.mandatory_fields).to include("access_id")
      expect(subject.mandatory_fields).to include("direction")
      expect(subject.mandatory_fields).to include("final_access_value")
    end
  end

  describe ".description" do
    it "returns the correct text" do
      access = build(:access)
      access_transaction.access = access
      msg = "#{access_transaction.action.gsub('access', '').humanize}: #{access.name}"
      expect(access_transaction.description).to eq(msg)
    end
  end
end
