require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "datetime" do
    context "correct datetime" do
      it "should not return nil" do
        expect(helper.datetime("2017-10-02T18:09:17")).not_to be(nil)
      end

      it "should return a Time object" do
        expect(helper.datetime("2017-10-02T18:09:17").class).to eql(ActiveSupport::TimeWithZone)
      end
    end

    context "incorrect datetime" do
      it "should return nil" do
        expect(helper.datetime("2017-10-01T00:37:300T16:53:22")).to be(nil)
      end
    end
  end

  describe "title" do
    context "production environment" do
      before(:each) { allow(Rails).to receive(:env) { "production".inquiry } }

      it "should return Glownet" do
        expect(helper.title).to eql("Glownet")
      end
    end

    context "other environment" do
      before(:each) { allow(Rails).to receive(:env) { "development".inquiry } }

      it "should return [:env.upcase}] Glownet" do
        expect(helper.title).to eql("[DEVELOPMENT] Glownet")
      end
    end
  end

  describe "number_to_token" do
    before(:each) { @current_event = create(:event) }

    context "pass a number" do
      it "should return Glownet" do
        expect(helper.number_to_token('1')).to eql("1.00 ☉")
      end
    end

    context "pass wrong data" do
      it "should return [:env.upcase}] Glownet" do
        expect(helper.number_to_token(nil)).to eql(nil)
      end
    end
  end

  describe "number_to_currency" do
    before(:each) { @current_event = create(:event) }

    context "pass a number" do
      it "should return Glownet" do
        expect(helper.number_to_currency('1')).to eql("1.00 €")
      end
    end

    context "pass wrong data" do
      it "should return [:env.upcase}] Glownet" do
        expect(helper.number_to_currency(nil)).to eql(nil)
      end
    end
  end
end
