require "spec_helper"

RSpec.describe EventSerie, type: :model do
  let(:event_serie) { build(:event_serie) }

  it "has a valid factory" do
    expect(event_serie).to be_valid
  end

  it "has a name" do
    expect(event_serie.name).not_to be_blank
  end
end
