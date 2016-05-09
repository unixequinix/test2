require "rails_helper"

RSpec.describe Payments::SofortDataRetriever, type: :domain_logic do
  let(:order) do
    create(:order)
  end

  let(:event) do
    order.profile.event
  end

  let(:sofort_data_retriever) do
    params = {}
    params[:consumer_ip_address] = "192.168.1.1"
    params[:consumer_user_agent] = "chrome"

    Payments::SofortDataRetriever.new(event, order).with_params(params)
  end

  context ".url_for_redirection" do
    it "should return an url needed for redirection when wirecard option is chosen" do
      binding.pry
      expect(:sofort_data_retriever).to receive(:url_for_redirection).and_return(14)
      binding.pry

    end
  end
end
