require "spec_helper"

RSpec.describe Device, type: :model do
  let(:device) { build(:device) }

  it "has a valid factory" do
    expect(device).to be_valid
  end
end
