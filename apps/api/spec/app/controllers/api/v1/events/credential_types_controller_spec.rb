require "spec_helper"

RSpec.describe Api::V1::Events::CredentialTypesController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { Admin.first || create(:admin) }
  let(:db_credential_types) do
    CredentialType.joins(:catalog_item).where(catalog_items: { event_id: event.id }).pluck(:id)
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
        create_list(:credential_type,
                    5,
                    catalog_item: create(:catalog_item, :with_access, event: event))
      end

      it "has a 200 status code" do
        get :index, event_id: event.id

        expect(response.status).to eq 200
      end

      it "returns all the credential types" do
        get :index, event_id: event.id

        body = JSON.parse(response.body)
        credential_types = body.map { |m| m["id"] }
        expect(credential_types).to eq(db_credential_types)
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
