require "spec_helper"

RSpec.describe ApplicationHelper, type: :helper do
  subject { ApplicationHelper }

  describe ".title" do
    before { @env = Rails.env }

    it "returns a different title depending on the enviroment" do
      allow(@env).to receive(:production?).and_return(false)
      expect(title).to eq("[#{Rails.env.upcase}] Glownet")
    end

    it "returns only glownet if enviroment is production" do
      allow(@env).to receive(:production?).and_return(true)
      expect(title).to eq("Glownet")
    end
  end

  describe ".format_abstract_value" do
    before { allow(subject).to receive(:fa_icon).and_return "icon" }

    it "return an icon when true" do
      expect(format_abstract_value(true)).to include?("icon")
    end
  end
end
