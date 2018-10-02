require "rails_helper"

RSpec.describe Credit, type: :model do
  subject { create(:credit) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "has a valid symbol" do
    expect(subject.symbol).to_not be_nil
  end

  describe ".credits" do
    it "returns 1" do
      expect(subject.credits).to eq(1)
    end
  end
end
