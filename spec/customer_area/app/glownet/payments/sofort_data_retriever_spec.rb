require "rails_helper"

RSpec.describe Payments::SofortDataRetriever, type: :domain_logic do
  context ".url_for_redirection" do
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

    it "should return an url needed for redirection when wirecard option is chosen" do
    end
  end
end
