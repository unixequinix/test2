require "spec_helper"

RSpec.describe Api::V1::Events::CustomersController, type: :controller do
  let(:admin) { Admin.first || FactoryGirl.create(:admin) }

  before(:all) do
    @event = create(:event)
    @customer1 = create(:customer_event_profile, event: @event)

    create(:credential_assignment_g_a, customer_event_profile: @customer1)

    create_list(:customer_order,
                5,
                customer_event_profile: @customer1,
                catalog_item: create(:catalog_item, :with_access, event: @event))
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
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
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(401)
      end
    end
  end
end
