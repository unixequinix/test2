require 'rails_helper'

RSpec.describe Api::V2::Events::RefundsController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let!(:customer_portal) { create(:station, category: "customer_portal", event: event) }
  let(:user) { create(:user) }
  let(:customer) { create(:customer, event: event) }
  let(:gtag) { create(:gtag, customer: customer, event: event, active: true) }
  let(:refund) { create(:refund, event: event, customer: customer) }

  let(:invalid_attributes) { { credit_base: nil } }
  let(:valid_attributes) { { credit_base: 100, fields: { iban: "barrr", swift: "fooo" }, customer_id: customer.id, gateway: "paypal" } }

  before do
    token_login(user, event)
    gtag.update!(final_balance: 150)
  end

  describe "GET #index" do
    before { create_list(:refund, 3, event: event, customer: customer) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all refunds" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(3)
    end

    it "does not return refunds from another event" do
      new_event = create(:event, open_api: true, state: "created")
      new_customer = create(:customer, event: new_event)
      create(:gtag, customer: new_customer, event: new_event, credits: 150)
      new_refund = create(:refund, customer: new_customer, event: new_event, credit_base: 10, credit_fee: 0)
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json_v2(new_refund, "RefundSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: refund.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the refund as JSON" do
      get :show, params: { event_id: event.id, id: refund.to_param }
      expect(json).to eq(obj_to_json_v2(refund, "RefundSerializer"))
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Refund" do
        expect do
          post :create, params: { event_id: event.id, refund: valid_attributes }
        end.to change(Refund, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, refund: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created refund" do
        post :create, params: { event_id: event.id, refund: valid_attributes }
        expect(json["id"]).to eq(Refund.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, refund: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { gateway: "bank_account" } }

      before { refund }

      it "updates the requested refund" do
        expect do
          put :update, params: { event_id: event.id, id: refund.to_param, refund: new_attributes }
        end.to change { refund.reload.gateway }.to("bank_account")
      end

      it "returns the refund" do
        put :update, params: { event_id: event.id, id: refund.to_param, refund: valid_attributes }
        expect(json["id"]).to eq(refund.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: refund.to_param, refund: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #complete" do
    context "when not already completed" do
      before { refund.started! }

      it "updates the requested refunds status to completed" do
        expect do
          put :complete, params: { event_id: event.id, id: refund.to_param }
        end.to change { refund.reload.status }.to("completed")
      end

      it "returns the refund" do
        put :complete, params: { event_id: event.id, id: refund.to_param }
        expect(json["id"]).to eq(refund.id)
      end
    end

    context "when already completed" do
      before { refund.completed! }

      it "returns an unprocessable_entity response" do
        put :complete, params: { event_id: event.id, id: refund.to_param }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #cancel" do
    context "when not already cancelled" do
      before { refund.complete! }

      it "updates the requested refunds status to cancelled" do
        expect do
          put :cancel, params: { event_id: event.id, id: refund.to_param }
        end.to change { refund.reload.status }.to("cancelled")
      end

      it "returns the refund" do
        put :cancel, params: { event_id: event.id, id: refund.to_param }
        expect(json["id"]).to eq(refund.id)
      end
    end

    context "when already cancelled" do
      before { refund.cancelled! }

      it "returns an unprocessable_entity response" do
        put :cancel, params: { event_id: event.id, id: refund.to_param }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      refund
      user.admin!
    end

    it "destroys the requested refund" do
      expect do
        delete :destroy, params: { event_id: event.id, id: refund.to_param }
      end.to change(Refund, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: refund.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
