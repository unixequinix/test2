require "rails_helper"

RSpec.describe Api::V1::Events::AccessesController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:db_accesses) do
    Access.joins(:catalog_item).where(catalog_items: { event_id: event.id })
  end

  before do
    create(:catalog_item, :with_access, event: event)
    @new_access = create(:catalog_item, :with_access, event: event)
    @new_access.update!(updated_at: Time.now + 4.hours)
    @new_access.catalogable.update!(updated_at: Time.now + 4.hours)
  end

  describe "GET index" do
    context "when authenticated" do
      before do
        http_login(admin.email, admin.access_token)
      end

      it "returns a 200 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 200
      end

      it "returns the necessary keys" do
        get :index, event_id: event.id
        JSON.parse(response.body).map do |access|
          expect(access.keys).to eq(%w(id name mode position memory_length description))
        end
      end

      it "returns the correct data" do
        get :index, event_id: event.id
        JSON.parse(response.body).each_with_index do |access, index|
          access_atts = {
            id: db_accesses[index].id,
            name: db_accesses[index].catalog_item.name,
            mode: db_accesses[index].entitlement.mode,
            position: db_accesses[index].entitlement.memory_position,
            memory_length: db_accesses[index].entitlement.memory_length.to_i,
            description: db_accesses[index].catalog_item.description
          }
          expect(access_atts.as_json).to eq(access)
        end
      end

      context "with the 'If-Modified-Since' header" do
        it "returns only the modified accesses" do
          request.headers["If-Modified-Since"] = (@new_access.updated_at - 2.hours)
          get :index, event_id: event.id
          accesses = JSON.parse(response.body).map { |m| m["id"] }
          expect(accesses).to eq([@new_access.catalogable_id])
        end
      end

      context "without the 'If-Modified-Since' header" do
        it "returns all the accesses" do
          get :index, event_id: event.id
          api_accesses = JSON.parse(response.body).map { |m| m["id"] }
          expect(api_accesses).to eq(db_accesses.pluck(:id))
        end
      end
    end

    context "when unauthenticated" do
      it "returns a 401 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq 401
      end
    end
  end
end
