require "rails_helper"

RSpec.describe PaymentGatewaysHelper, type: :helper do
  let(:event) { create(:event, auto_refunds: true) }
  let(:customer) { create(:customer, event: event) }

  before(:each) { sign_in customer }

  context "with wiredlion" do
    context "orders redirection" do
      it "should be to wiredlion" do
        expect(helper.store_redirection(event, :order)).to include("wiredlion")
      end

      it "should contain the glownet portion of the URL" do
        expect(helper.store_redirection(event, :order)).to include("register")
      end

      it "should contain the customer id" do
        expect(helper.store_redirection(event, :order)).to include(customer.id.to_s)
      end
    end

    context "refunds redirection" do
      before(:each) do
        create(:gtag, event: event, customer: customer)
      end

      it "should not be new refunds path" do
        expect(helper.store_redirection(event, :refund, gtag_uid: customer.active_gtag.tag_uid)).not_to eql(new_event_refund_path(event))
      end

      it "should contain the glownet portion of the URL" do
        expect(helper.store_redirection(event, :refund, gtag_uid: customer.active_gtag.tag_uid)).to include("refund")
      end

      it "should contain the customer email" do
        expect(helper.store_redirection(event, :refund, gtag_uid: customer.active_gtag.tag_uid)).to include(customer.email.split("@").first)
      end

      it "should contain the customer gtag_id" do
        expect(helper.store_redirection(event, :refund, gtag_uid: customer.active_gtag.tag_uid)).to include(customer.active_gtag.tag_uid)
      end
    end

    it "should contain dev if environment is not production" do
      expect(helper.store_redirection(event, :order)).to include("dev")
    end

    it "should contain the event slug" do
      expect(helper.store_redirection(event, :order)).to include(event.slug)
    end

    it "should contain the protocol HTTPS" do
      expect(helper.store_redirection(event, :order)).to include("http")
    end
  end
end
