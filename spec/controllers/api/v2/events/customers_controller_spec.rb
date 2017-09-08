require 'rails_helper'

RSpec.describe Api::V2::Events::CustomersController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:customer) { create(:customer, event: event) }

  let(:invalid_attributes) { { email: "aaa" } }
  let(:valid_attributes) { { first_name: "test customer", last_name: "foo" } }

  before { token_login(user, event) }

  describe "GET #index" do
    before { create_list(:customer, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all customers" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return customers from another event" do
      customer.update!(event: create(:event))
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json(customer, "Simple::CustomerSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: customer.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the customer as JSON" do
      get :show, params: { event_id: event.id, id: customer.to_param }
      expect(json).to eq(obj_to_json(customer, "Full::CustomerSerializer"))
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Customer" do
        expect do
          post :create, params: { event_id: event.id, customer: valid_attributes }
        end.to change(Customer, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, customer: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created customer" do
        post :create, params: { event_id: event.id, customer: valid_attributes }
        expect(json["id"]).to eq(Customer.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, customer: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { first_name: "new name" } }

      before { customer }

      it "updates the requested customer" do
        expect do
          put :update, params: { event_id: event.id, id: customer.to_param, customer: new_attributes }
        end.to change { customer.reload.first_name }.to("new name")
      end

      it "returns the customer" do
        put :update, params: { event_id: event.id, id: customer.to_param, customer: valid_attributes }
        expect(json["id"]).to eq(customer.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: customer.to_param, customer: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { customer }

    it "destroys the requested customer" do
      expect do
        delete :destroy, params: { event_id: event.id, id: customer.to_param }
      end.to change(Customer, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: customer.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
