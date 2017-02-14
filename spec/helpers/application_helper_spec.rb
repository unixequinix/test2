require "spec_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe ".title" do
    before { @env = Rails.env }

    it "returns a different title depending on the enviroment" do
      allow(@env).to receive(:production?).and_return(false)
      expect(helper.title).to eq("[#{Rails.env.upcase}] Glownet")
    end

    it "returns only glownet if enviroment is production" do
      allow(@env).to receive(:production?).and_return(true)
      expect(helper.title).to eq("Glownet")
    end
  end

  describe ".number_to_token" do
    before { @current_event = create(:event) }

    it "returns the value of the number" do
      expect(helper.number_to_token(10)).to include("10")
    end
  end
end
