require "rails_helper"

RSpec.describe Device, type: :model do
  it "has a valid factory" do
    expect(build(:device)).to be_valid
  end
end
