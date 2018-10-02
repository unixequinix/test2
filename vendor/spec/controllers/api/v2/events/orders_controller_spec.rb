require 'rails_helper'

RSpec.describe Api::V2::Events::OrdersController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user, role: :admin) }
  let(:order) { create(:order, event: event) }
  let(:customer) { create(:customer, event: event) }

  let(:invalid_attributes) { { status: nil } }
  let(:valid_attributes) { { status: "completed", gateway: "paypal", customer_id: customer.id } }

  before { token_login(user, event) }

  describe "GET #index" do
    before { create_list(:order, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all orders" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return orders from another event" do
      new_order = create(:order)
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json_v2(new_order, "OrderSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: order.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the order as JSON" do
      get :show, params: { event_id: event.id, id: order.to_param }
      expect(json).to eq(obj_to_json_v2(order, "OrderSerializer"))
    end
  end

  describe "PUT #complete" do
    let(:valid_attributes) { { gateway: "paypal" } }

    context "when not already completed" do
      before { order.started! }

      it "updates the requested orders status to completed" do
        expect do
          put :complete, params: { event_id: event.id, id: order.to_param, order: valid_attributes }
        end.to change { order.reload.status }.to("completed")
      end

      it "returns the order" do
        put :complete, params: { event_id: event.id, id: order.to_param, order: valid_attributes }
        expect(json["id"]).to eq(order.id)
      end
    end

    context "when already completed" do
      before { order.completed! }

      it "returns an unprocessable_entity response" do
        put :complete, params: { event_id: event.id, id: order.to_param }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { order }

    it "destroys the requested order" do
      expect do
        delete :destroy, params: { event_id: event.id, id: order.to_param }
      end.to change(Order, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: order.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
