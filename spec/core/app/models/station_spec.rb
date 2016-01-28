require 'rails_helper'

RSpec.describe Station, type: :model do
  let(:station) { build(:station) }

  it "is expected to be valid" do
    expect(station).to be_valid
  end
end
