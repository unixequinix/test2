require 'rails_helper'

RSpec.describe Api::V2::Events::OrdersController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user, role: "admin") }
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
      expect(json).not_to include(obj_to_json(new_order, "OrderSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: order.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the order as JSON" do
      get :show, params: { event_id: event.id, id: order.to_param }
      expect(json).to eq(obj_to_json(order, "OrderSerializer"))
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Order" do
        expect do
          post :create, params: { event_id: event.id, order: valid_attributes }
        end.to change(Order, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, order: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created order" do
        post :create, params: { event_id: event.id, order: valid_attributes }
        expect(json["id"]).to eq(Order.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, order: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { status: "cancelled" } }

      before { order }

      it "updates the requested order" do
        expect do
          put :update, params: { event_id: event.id, id: order.to_param, order: new_attributes }
        end.to change { order.reload.status }.to("cancelled")
      end

      it "returns the order" do
        put :update, params: { event_id: event.id, id: order.to_param, order: valid_attributes }
        expect(json["id"]).to eq(order.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: order.to_param, order: invalid_attributes }
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
