require "spec_helper"

RSpec.describe ApplicationHelper, type: :helper do
  subject { ApplicationHelper }

  describe ".title" do
    it "returns a different title depending on the enviroment" do
      allow(Rails).to receive(:env).and_return("staging")
      expect(title).to eq("[STAGING] Glownet")
    end

    it "returns only glownet if enviroment is production" do
      allow(Rails).to receive(:env).and_return("production")
      expect(title).to eq("Glownet")
    end
  end
end
