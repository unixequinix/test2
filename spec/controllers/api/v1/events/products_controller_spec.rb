require "spec_helper"

RSpec.describe Api::V1::Events::ProductsController, type: :controller do
  let(:event) { create(:event) }
  let(:user) { create(:user) }
  let(:db_products) { event.products }

  before do
    create(:product, event: event)
    @new_product = create(:product, event: event, updated_at: Time.zone.now + 4.hours)
  end

  describe "GET index" do
    context "when authenticated" do
      before { http_login(user.email, user.access_token) }

      it "returns a 200 status code" do
        get :index, params: { event_id: event.id }
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        get :index, params: { event_id: event.id }
        product_keys = %w[id name description is_alcohol]
        JSON.parse(response.body).map { |product| expect(product.keys).to eq(product_keys) }
      end

      context "with the 'If-Modified-Since' header" do
        it "returns only the modified products" do
          request.headers["If-Modified-Since"] = (@new_product.updated_at - 2.hours)
          get :index, params: { event_id: event.id }
          products = JSON.parse(response.body).map { |m| m["id"] }
          expect(products).to eq([@new_product.id])
        end
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the products" do
          get :index, params: { event_id: event.id }
          api_products = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_products).to eq(db_products.map(&:id))
        end
      end
    end

    context "when unauthenticated" do
      it "returns a 401 status code" do
        get :index, params: { event_id: event.id }
        expect(response).to be_unauthorized
      end
    end
  end
end
