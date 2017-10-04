require "rails_helper"

RSpec.describe PaymentGatewaysHelper, type: :helper do
  let(:event) { create(:event) }
  let(:customer) { create(:customer, event: event) }

  before(:each) { sign_in customer }

  context "without vouchup" do
    it "returns new orders path if no vouchup is found in payment_gateways" do
      expect(helper.store_redirection(event)).to eql(new_event_order_path(event))
    end
  end

  context "with vouchup" do
    before { create(:payment_gateway, name: "vouchup", topup: true, event: event) }

    it "should not be new orders path" do
      expect(helper.store_redirection(event)).not_to eql(new_event_order_path(event))
    end

    it "should contain dev if environment is not production" do
      expect(helper.store_redirection(event)).to include("dev")
    end

    it "should contain the event slug" do
      expect(helper.store_redirection(event)).to include(event.slug)
    end

    it "should contain the protocol HTTPS" do
      expect(helper.store_redirection(event)).to include("https")
    end

    it "should contain the customer id" do
      expect(helper.store_redirection(event)).to include(customer.id.to_s)
    end

    it "should contain the glownet portion of the URL" do
      expect(helper.store_redirection(event)).to include("glownet")
    end
  end
end
