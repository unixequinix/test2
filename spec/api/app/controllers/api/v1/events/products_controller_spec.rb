require "rails_helper"

RSpec.describe Api::V1::Events::ProductsController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { Admin.first || create(:admin) }
  let(:db_products) do
    Product.where(event_id: event.id).pluck(:id)
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
        create_list(:product, 5, event: event)
      end

      it "has a 200 status code" do
        get :index, event_id: event.id

        expect(response.status).to eq 200
      end

      it "returns all the packs" do
        get :index, event_id: event.id

        body = JSON.parse(response.body)
        products = body.map { |m| m["id"] }

        expect(products).to eq(db_products)
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: event.id

        expect(response.status).to eq 401
      end
    end
  end
end
