require "spec_helper"

RSpec.describe Api::V1::Events::CustomersController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:customer) { create(:customer, event: event) }
  let(:item) { create(:access, event: event) }
  let(:db_customers) { event.customers }

  describe "GET index" do
    context "with authentication" do
      before do
        create(:gtag, customer: customer)
        order = create(:order, customer: customer)
        create(:order_item, order: order, catalog_item: item)
      end

      before(:each) do
        http_login(admin.email, admin.access_token)
        get :index, event_id: event.id
      end

      it "returns a 200 status code" do
        expect(response.status).to eq(200)
      end

      it "returns the necessary keys" do
        cus_keys = %w(id banned updated_at first_name last_name email credentials orders)
        cre_keys = %w(customer_id reference type)
        order_keys = %w(customer_id online_order_counter amount catalog_item_id redeemed)

        JSON.parse(response.body).map do |gtag|
          expect(gtag.keys).to eq(cus_keys)
          expect(gtag["credentials"].map(&:keys).flatten.uniq).to eq(cre_keys)
          expect(gtag["orders"].map(&:keys).flatten.uniq).to eq(order_keys)
        end
      end

      it "returns the correct reference of the credentiable" do
        JSON.parse(response.body).map do |c|
          api_cred = c["credentials"]
          db_cred = Customer.find(c["id"]).active_credentials.map do |obj|
            { customer_id: obj.customer_id, reference: obj.reference, type: obj.class.name.downcase }.as_json
          end
          expect(api_cred).to eq(db_cred)
        end
      end
    end

    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq(401)
      end
    end
  end
end
