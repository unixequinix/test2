require 'rails_helper'

RSpec.describe Api::V2::Events::GtagsController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:gtag) { create(:gtag, event: event) }

  let(:invalid_attributes) { { tag_uid: nil } }
  let(:valid_attributes) { { tag_uid: "FEAA11EE2244" } }

  before { token_login(user, event) }

  describe "GET #index" do
    before { create_list(:gtag, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all gtags" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return gtags from another event" do
      new_gtag = create(:gtag)
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json(new_gtag, "Simple::GtagSerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: gtag.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the gtag as JSON" do
      get :show, params: { event_id: event.id, id: gtag.to_param }
      expect(json).to eq(obj_to_json(gtag, "GtagSerializer"))
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Gtag" do
        expect do
          post :create, params: { event_id: event.id, gtag: valid_attributes }
        end.to change(Gtag, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, gtag: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created gtag" do
        post :create, params: { event_id: event.id, gtag: valid_attributes }
        expect(json["id"]).to eq(Gtag.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, gtag: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { tag_uid: "1111111111" } }

      before { gtag }

      it "updates the requested gtag" do
        expect do
          put :update, params: { event_id: event.id, id: gtag.to_param, gtag: new_attributes }
        end.to change { gtag.reload.tag_uid }.to("1111111111")
      end

      it "returns the gtag" do
        put :update, params: { event_id: event.id, id: gtag.to_param, gtag: valid_attributes }
        expect(json["id"]).to eq(gtag.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: gtag.to_param, gtag: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { gtag }

    it "destroys the requested gtag" do
      expect do
        delete :destroy, params: { event_id: event.id, id: gtag.to_param }
      end.to change(Gtag, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: gtag.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
