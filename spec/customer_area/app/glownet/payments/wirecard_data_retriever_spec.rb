require "rails_helper"

RSpec.describe Payments::Wirecard::DataRetriever, type: :domain_logic do
  let(:order) do
    create(:order)
  end

  let(:event) do
    order.profile.event
  end


  subject do
    EventParameter.find_or_create_by(event: event,
                                    value: "SECRETSECRET",
                                    parameter: Parameter.find_by(category: "payment",
                                                                 group: "wirecard",
                                                                 name: "secret_key"))
    params = {
      consumer_ip_address: "192.168.1.1",
      consumer_user_agent: "chrome"
    }
    Payments::Wirecard::DataRetriever.new(event, order).with_params(params)
  end

  context ".payment_type" do
    it "should return the payment_type for Wirecard Credit Card" do
      expect(subject.payment_type).to eq("CCARD")
    end
  end

  context ".shop_id" do
    it "should return the shop_id for Wirecard Credit Card" do
      expect(subject.shop_id).to eq("qmore")
    end
  end

  context ".order_ident" do
    it "should return the order_ident for Wirecard Credit Card" do
      expect(subject.order_ident).to be_kind_of(Integer)
      expect(subject.order_ident).to have(8).digits
    end
  end

  context ".auto_deposit" do
    it "should return the auto_deposit for Wirecard Credit Card" do
      expect(subject.auto_deposit).to eq("no")
    end
  end

  context ".duplicate_request_check" do
    it "should return the duplicate_request_check for Wirecard Credit Card" do
      expect(subject.duplicate_request_check).to eq("false")
    end
  end

  context ".window_name" do
    it "should return the window_name for Wirecard Credit Card" do
      expect(subject.window_name).to eq("wirecard-credit-card")
    end
  end

  context ".success_url" do
    it "should return the success_url for Wirecard Credit Card" do
      expect(subject.success_url).to include("payment_services/wirecard/asynchronous_payments/success")
    end
  end

  context ".failure_url" do
    it "should return the failure_url for Wirecard Credit Card" do
      expect(subject.failure_url).to include("payment_services/wirecard/asynchronous_payments/error")
    end
  end

  context ".confirm_url" do
    it "should return the confirm_url for Wirecard Credit Card" do
      expect(subject.confirm_url).to include("payment_services/wirecard/asynchronous_payments")
    end
  end

  context ".return_url" do
    it "should return the return_url for Wirecard Credit Card" do
      expect(subject.return_url).to include("http://")
    end
  end

  context ".noscript_info_url" do
    it "should return the noscript_info_url for Wirecard Credit Card" do
      expect(subject.noscript_info_url).to include("http://")
    end
  end
end
