require "rails_helper"

RSpec.describe Api::V1::Events::GtagsController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:db_gtags) { event.gtags }

  before do
    create_list(:gtag, 2, event: event)
    @deleted_gtag = create(:gtag, :with_purchaser, event: event, deleted_at: Time.zone.now)
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
        get :index, event_id: event.id
      end

      it "returns a 200 status code" do
        expect(response.status).to eq(200)
      end

      it "returns the necessary keys" do
        JSON.parse(response.body).map do |gtag|
          keys = %w(reference banned updated_at customer_id)
          expect(gtag.keys).to eq(keys)
        end
      end

      it "returns the correct data" do
        JSON.parse(response.body).each do |list_gtag|
          gtag = db_gtags[db_gtags.index { |tag| tag.tag_uid == list_gtag["reference"] }]
          expect(list_gtag["reference"]).to eq(gtag.tag_uid)
          expect(list_gtag["banned"]).to eq(gtag.banned?)
          expect(list_gtag["customer_id"]).to eq(gtag&.profile&.id)
          updated_at = Time.zone.parse(list_gtag["updated_at"]).strftime("%Y-%m-%dT%T.%6N")
          expect(updated_at).to eq(gtag.updated_at.utc.strftime("%Y-%m-%dT%T.%6N"))
        end
      end

      it "doesn't returns deleted gtags" do
        gtags = JSON.parse(response.body).map { |gtag| gtag["id"] }
        expect(gtags).not_to include(@deleted_gtag.id)
      end
    end

    context "without authentication" do
      it "returns a 401 status code" do
        get :index, event_id: event.id
        expect(response.status).to eq(401)
      end
    end
  end

  describe "GET show" do
    context "with authentication" do
      before do
        @access = create(:access_catalog_item, event: event)
        @profile = create(:profile, event: event)
        @gtag = create(:gtag, event: event, profile: @profile)
        @gtag2 = create(:gtag, event: event, profile: @profile, active: false)
        @customer = create(:customer, profile: @profile)
        @order = create(:customer_order, profile: @profile, catalog_item: @access, counter: 1)

        http_login(admin.email, admin.access_token)
      end

      describe "when gtag exists" do
        before(:each) do
          get :show, event_id: event.id, id: @gtag.tag_uid
        end

        it "returns a 200 status code" do
          expect(response.status).to eq(200)
        end

        it "returns the necessary keys" do
          gtag = JSON.parse(response.body)
          gtag_keys = %w(reference banned customer)
          customer_keys = %w(id banned autotopup_gateways credentials first_name last_name email orders)
          order_keys = %w(online_order_counter catalogable_id catalogable_type amount)
          credential_keys = %w(reference type)

          expect(gtag.keys).to eq(gtag_keys)
          expect(gtag["customer"].keys).to eq(customer_keys)
          expect(gtag["customer"]["credentials"].map(&:keys).flatten.uniq).to eq(credential_keys)
          expect(gtag["customer"]["orders"].map(&:keys).flatten.uniq).to eq(order_keys)
        end

        it "returns the correct data" do
          customer = @gtag.profile.customer
          orders = @gtag.profile.customer_orders

          gtag = {
            reference: @gtag.tag_uid,
            banned: @gtag.banned,
            customer: {
              id:  @gtag.profile.id,
              banned: @gtag.profile.banned?,
              autotopup_gateways: [],
              credentials: [{ reference: @gtag.tag_uid, type: "gtag" }],
              first_name: customer.first_name,
              last_name: customer.last_name,
              email: customer.email,
              orders: [{
                online_order_counter: orders.first.counter,
                catalogable_id: orders.first.catalog_item.catalogable_id,
                catalogable_type: orders.first.catalog_item.catalogable_type.downcase,
                amount: orders.first.amount
              }]
            }
          }

          expect(JSON.parse(response.body)).to eq(gtag.as_json)
        end
      end

      describe "when gtag doesn't exist" do
        it "returns a 404 status code" do
          get :show, event_id: event.id, id: (Gtag.last.id + 10)
          expect(response.status).to eq(404)
        end
      end
    end

    context "without authentication" do
      it "returns a 401 status code" do
        get :show, event_id: event.id, id: Gtag.last.id
        expect(response.status).to eq(401)
      end
    end
  end
end
