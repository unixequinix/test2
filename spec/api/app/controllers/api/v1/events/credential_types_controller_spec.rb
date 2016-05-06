require "rails_helper"

RSpec.describe Api::V1::Events::CredentialTypesController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:db_cred_types) do
    CredentialType.joins(:catalog_item).where(catalog_items: { event_id: event.id })
  end

  describe "GET index" do
    context "with authentication" do
      before do
        http_login(admin.email, admin.access_token)
        catalog_item = create(:catalog_item, :with_access, event: event)
        create_list(:credential_type, 5, catalog_item: catalog_item)
      end

      before(:each) { get :index, event_id: event.id }

      it "has a 200 status code" do
        expect(response.status).to eq(200)
      end

      it "returns the necessary keys" do
        JSON.parse(response.body).map do |cred_type|
          expect(cred_type.keys).to eq(%w(id position catalogable_id catalogable_type ))
        end
      end

      it "returns the correct data" do
        JSON.parse(response.body).each_with_index do |cred_type, index|
          cred_type_atts = {
            id: db_cred_types[index].id,
            position: db_cred_types[index].memory_position,
            catalogable_id: db_cred_types[index].catalog_item.catalogable_id,
            catalogable_type: db_cred_types[index].catalog_item.catalogable_type.downcase
          }
          expect(cred_type_atts.as_json).to eq(cred_type)
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
