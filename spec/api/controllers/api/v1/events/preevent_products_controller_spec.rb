require "rails_helper"

RSpec.describe Api::V1::Events::PreeventProductsController, type: :controller do
  describe "GET index" do
    before(:all) do
      @event = create(:event)
      create(:preevent_product, :credit_product, event: @event)
      create(:preevent_product, :credential_product, event: @event)
      create(:preevent_product, :voucher_product, event: @event)
    end

    context "with authentication" do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        http_login(@admin.email, @admin.access_token)
        get :index, event_id: @event.id
      end

      it "returns a 200 status code" do
        expect(response.status).to eq(200)
      end

      it "returns the list of preevent products" do
        body = JSON.parse(response.body)
        parameters = body.map { |m| m["name"] }

        expect(parameters).to match_array(PreeventProduct.all.map(&:name))
      end
    end

    context "without authentication" do
      it "returns a 401 status code" do
        get :index, event_id: @event.id
        expect(response.status).to eq(401)
      end
    end
  end
end
