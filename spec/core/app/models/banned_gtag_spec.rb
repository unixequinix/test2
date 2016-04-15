require "rails_helper"

RSpec.describe BannedGtag, type: :model do
  let(:banned_gtag) { build(:banned_gtag) }

  it "is expected to be valid" do
    expect(banned_gtag).to be_valid
  end
end
