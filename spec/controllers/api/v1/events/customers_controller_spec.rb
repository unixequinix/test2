require "rails_helper"

RSpec.describe Api::V1::Events::CustomersController, type: :controller do
  let(:event) { create(:event, open_devices_api: true) }
  let(:user) { create(:user) }
  let(:customer) { create(:customer, event: event) }
  let(:item) { create(:access, event: event) }
  let(:db_customers) { event.customers }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }

  describe "GET index" do
    context "with authentication" do
      before do
        create(:gtag, customer: customer, event: event)
        order = create(:order, customer: customer, status: "completed", event: event)
        create(:order_item, order: order, catalog_item: item, counter: 1)
      end

      before(:each) do
        http_login(user.email, user.access_token)
        get :index, params: params
      end

      it "returns a 200 status code" do
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        cus_keys = %w[id updated_at first_name last_name email credentials orders].sort
        cre_keys = %w[customer_id reference redeemed type].sort
        order_keys = %w[counter id customer_id amount catalog_item_id catalog_item_type redeemed status].sort

        JSON.parse(response.body).map do |gtag|
          expect(gtag.keys.sort).to eq(cus_keys)
          expect(gtag["credentials"].map(&:keys).flatten.uniq.sort).to eq(cre_keys)
          expect(gtag["orders"].map(&:keys).flatten.uniq.sort).to eq(order_keys)
        end
      end

      it "returns the correct reference of the credentiable" do
        JSON.parse(response.body).map do |c|
          api_cred = c["credentials"]
          db_cred = Customer.find(c["id"]).active_credentials.map do |obj|
            { customer_id: obj.customer_id, reference: obj.reference, redeemed: obj.redeemed?, type: obj.class.name.downcase }.as_json
          end
          expect(api_cred).to eq(db_cred)
        end
      end
    end

    context "without authentication" do
      it "has a 401 status code" do
        get :index, params: params
        expect(response).to be_unauthorized
      end
    end
  end
end
