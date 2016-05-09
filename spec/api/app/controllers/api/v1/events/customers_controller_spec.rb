require "rails_helper"

RSpec.describe Api::V1::Events::CustomersController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:profile) { create(:profile, event: event) }
  let(:item) { create(:catalog_item, :with_access, event: event) }
  let(:db_profiles) { event.profiles }

  describe "GET index" do
    context "with authentication" do
      before do
        create(:credential_assignment_g_a, profile: profile)
        order = create(:customer_order, profile: profile, catalog_item: item)
        create(:online_order, customer_order: order)
      end

      before(:each) do
        http_login(admin.email, admin.access_token)
        get :index, event_id: event.id
      end

      it "returns a 200 status code" do
        expect(response.status).to eq(200)
      end

      it "returns the necessary keys" do
        cus_keys = %w(id banned first_name last_name email autotopup_gateways credentials orders)
        cre_keys = %w(id type)
        order_keys = %w(online_order_counter amount catalogable_id catalogable_type)

        JSON.parse(response.body).map do |gtag|
          expect(gtag.keys).to eq(cus_keys)
          expect(gtag["credentials"].map(&:keys).flatten.uniq).to eq(cre_keys)
          expect(gtag["orders"].map(&:keys).flatten.uniq).to eq(order_keys)
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
