require "rails_helper"

RSpec.describe Api::V1::Events::CustomersController, type: :controller do
  before(:all) do
    @event = create(:event)
    @customer1 = create(:customer_event_profile, event: @event)

    create(:credential_assignment_g_a, customer_event_profile: @customer1)

    create_list(:customer_order,
                5,
                customer_event_profile: @customer1,
                preevent_product: create(:preevent_product, :credit_product))
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        http_login(@admin.email, @admin.access_token)
      end

      it "has a 200 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(200)
      end

      it "returns all the customer event profiles" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)
        customers = body.map { |m| m["id"] }
        expect(customers).to match_array(CustomerEventProfile.for_event(@event).map(&:id))
      end

      it "should include the orders" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)

        expect(body.first).to have_key("orders")
        expect(body.first["orders"]).not_to be_empty
      end

      it "should include the credentials" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)

        expect(body.first).to have_key("credentials")
        expect(body.first["credentials"]).not_to be_empty
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(401)
      end
    end
  end
end
