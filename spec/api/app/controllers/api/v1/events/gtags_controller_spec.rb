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
          keys = %w(id tag_uid credential_redeemed banned credential_type_id
                    purchaser_first_name purchaser_last_name purchaser_email customer_id)
          expect(keys).to eq(gtag.keys)
        end
      end

      it "returns the correct data" do
        JSON.parse(response.body).each do |list_gtag|
          gtag = db_gtags[db_gtags.index { |tag| tag.id == list_gtag["id"] }]
          gtag_atts = {
            id: gtag.id,
            tag_uid: gtag.tag_uid,
            credential_redeemed: gtag.credential_redeemed,
            credential_type_id: gtag&.company_ticket_type&.credential_type_id,
            banned: gtag.banned?,
            purchaser_first_name: gtag&.purchaser&.first_name,
            purchaser_last_name: gtag&.purchaser&.last_name,
            purchaser_email: gtag&.purchaser&.email,
            customer_id: gtag&.assigned_profile&.id
          }.as_json
          expect(list_gtag).to eq(gtag_atts)
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
        @agreement = create(:company_event_agreement, event: event)
        @access = create(:access_catalog_item, event: event)
        @credential = create(:credential_type, catalog_item: @access)
        @ctt = create(:company_ticket_type, company_event_agreement: @agreement,
                                            event: event,
                                            credential_type: @credential)
        @gtag = create(:gtag, event: event, company_ticket_type: @ctt)
        @gtag2 = create(:gtag, event: event, company_ticket_type: @ctt)
        @profile = create(:profile, event: event)
        create(:credential_assignment, credentiable: @gtag,
                                       profile: @profile,
                                       aasm_state: "assigned")
        create(:credential_assignment, credentiable: @gtag2,
                                       profile: @profile,
                                       aasm_state: "unassigned")
        @customer = create(:customer, profile: @profile)
        @order = create(:customer_order, profile: @profile, catalog_item: @access)
        create(:online_order, counter: 1, customer_order: @order, redeemed: false)

        http_login(admin.email, admin.access_token)
      end

      describe "when gtag exists" do
        before(:each) do
          get :show, event_id: event.id, id: @gtag.id
        end

        it "returns a 200 status code" do
          expect(response.status).to eq(200)
        end

        it "returns the necessary keys" do
          gtag = JSON.parse(response.body)
          gtag_keys = %w(id tag_uid credential_redeemed banned credential_type_id customer)
          customer_keys = %w(id banned autotopup_gateways credentials first_name last_name email
                             orders)
          order_keys = %w(online_order_counter catalogable_id catalogable_type amount)

          expect(gtag.keys).to eq(gtag_keys)
          expect(gtag["customer"].keys).to eq(customer_keys)
          expect(gtag["customer"]["credentials"].map(&:keys).flatten.uniq).to eq(%w(id type))
          expect(gtag["customer"]["orders"].map(&:keys).flatten.uniq).to eq(order_keys)
        end

        it "returns the correct data" do
          customer = @gtag.assigned_profile.customer
          orders = @gtag.assigned_profile.customer_orders

          gtag = {
            id: @gtag.id,
            tag_uid: @gtag.tag_uid,
            credential_redeemed: @gtag.credential_redeemed,
            banned: @gtag.banned,
            credential_type_id: @gtag.company_ticket_type.credential_type_id,
            customer: {
              id:  @gtag.assigned_profile.id,
              banned: @gtag.assigned_profile.banned?,
              autotopup_gateways: [],
              credentials: [{ id: @gtag.id, type: "gtag" }],
              first_name: customer.first_name,
              last_name: customer.last_name,
              email: customer.email,
              orders: [{
                online_order_counter: orders.first.online_order.counter,
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
