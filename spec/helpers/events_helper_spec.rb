require "spec_helper"

RSpec.describe EventsHelper, type: :helper do
  describe ".best_in_place_checkbox" do
    let(:url) { [:admins] }
    let(:result) { helper.best_in_place_checkbox(url) }

    it "returns option as: :checkbox" do
      expect(result).to include(as: :checkbox)
    end

    it "returns place_holder option" do
      expect(result).to include(:place_holder)
    end

    it "returns collection options" do
      expect(result).to include(:collection)
    end

    it "returns url passed" do
      expect(result).to include(url: url)
    end
  end
end
