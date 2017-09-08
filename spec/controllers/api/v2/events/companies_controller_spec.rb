require 'rails_helper'

RSpec.describe Api::V2::Events::CompaniesController, type: %i[controller api] do
  let(:event) { create(:event, open_api: true, state: "created") }
  let(:user) { create(:user) }
  let(:company) { create(:company, event: event) }

  let(:invalid_attributes) { { name: nil, access_token: nil } }
  let(:valid_attributes) { { name: "test company", access_token: "RYUHGHJKL" } }

  before { token_login(user, event) }

  describe "GET #index" do
    before { create_list(:company, 10, event: event) }

    it "returns a success response" do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
    end

    it "returns all companies" do
      get :index, params: { event_id: event.id }
      expect(json.size).to be(10)
    end

    it "does not return companies from another event" do
      company.update!(event: create(:event))
      get :index, params: { event_id: event.id }
      expect(json).not_to include(obj_to_json(company, "CompanySerializer"))
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { event_id: event.id, id: company.to_param }
      expect(response).to have_http_status(:ok)
    end

    it "returns the company as JSON" do
      get :show, params: { event_id: event.id, id: company.to_param }
      expect(json).to eq(obj_to_json(company, "CompanySerializer"))
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Company" do
        expect do
          post :create, params: { event_id: event.id, company: valid_attributes }
        end.to change(Company, :count).by(1)
      end

      it "returns a created response" do
        post :create, params: { event_id: event.id, company: valid_attributes }
        expect(response).to be_created
      end

      it "returns the created company" do
        post :create, params: { event_id: event.id, company: valid_attributes }
        expect(json["id"]).to eq(Company.last.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        post :create, params: { event_id: event.id, company: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "new name" } }

      before { company }

      it "updates the requested company" do
        expect do
          put :update, params: { event_id: event.id, id: company.to_param, company: new_attributes }
        end.to change { company.reload.name }.to("new name")
      end

      it "returns the company" do
        put :update, params: { event_id: event.id, id: company.to_param, company: valid_attributes }
        expect(json["id"]).to eq(company.id)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable_entity response" do
        put :update, params: { event_id: event.id, id: company.to_param, company: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    before { company }

    it "destroys the requested company" do
      expect do
        delete :destroy, params: { event_id: event.id, id: company.to_param }
      end.to change(Company, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { event_id: event.id, id: company.to_param }
      expect(response).to have_http_status(:ok)
    end
  end
end
