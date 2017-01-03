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

    it "attaches the token symbol for the event" do
      @current_event.token_symbol = "foo"
      expect(helper.number_to_token(10)).to include("foo")
    end
  end

  describe ".format_abstract_value" do
    it "return a check icon when true" do
      expect(helper.format_abstract_value(true)).to include('fa-check')
    end

    it "return a check icon when 'true' in string" do
      expect(helper.format_abstract_value('true')).to include('fa-check')
    end

    it "return a times icon when false" do
      expect(helper.format_abstract_value(false)).to include('fa-times')
    end

    it "return a times icon when 'false' in string" do
      expect(helper.format_abstract_value('false')).to include('fa-times')
    end

    it "return 'Empty' when nil" do
      expect(helper.format_abstract_value(nil)).to include('Empty')
    end

    it "return 'Empty' when empty string" do
      expect(helper.format_abstract_value('')).to include('Empty')
    end

    it "return the value itself otherwise" do
      expect(helper.format_abstract_value(1)).to eq(1)
      expect(helper.format_abstract_value("foo")).to eq("foo")
    end
  end
end
