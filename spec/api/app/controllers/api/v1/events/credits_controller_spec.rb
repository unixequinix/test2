require "rails_helper"

RSpec.describe Api::V1::Events::CreditsController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:db_credits) do
    Credit.joins(:catalog_item).where(catalog_items: { event_id: event.id })
  end

  describe "GET index" do
    context "with authentication" do
      before do
        create_list(:catalog_item, 2, :with_credit, event: event)
        http_login(admin.email, admin.access_token)
      end

      before(:each) { get :index, event_id: event.id }

      it "returns a 200 status code" do
        expect(response.status).to eq(200)
      end

      it "returns the necessary keys" do
        JSON.parse(response.body).map do |credit|
          expect(credit.keys).to eq(%w(id name description value standard currency))
        end
      end

      it "returns the correct data" do
        JSON.parse(response.body).each_with_index do |credit, index|
          credit_atts = {
            id: db_credits[index].id,
            name: db_credits[index].catalog_item.name,
            description: db_credits[index].catalog_item.description,
            value: db_credits[index].value,
            standard: db_credits[index].standard,
            currency: db_credits[index].currency
          }
          expect(credit_atts.as_json).to eq(credit)
        end
      end
    end

    context "without authentication" do
      it "returns a 401 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq(401)
      end
    end
  end
end
