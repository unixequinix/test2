require "rails_helper"

RSpec.describe Api::V1::Events::TicketsController, type: :controller do
  let(:event) { create(:event) }
  let(:admin) { create(:admin) }
  let(:db_tickets) { Ticket.where(event: event) }

  before do
    create_list(:ticket, 2, :with_purchaser, event: event)
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
        get :index, event_id: event.id
      end

      it "returns a 200 status code" do
        expect(response.status).to eq 200
      end
      it "returns the necessary keys" do
        JSON.parse(response.body).map do |ticket|
          keys = %w(id reference credential_redeemed credential_type_id purchaser_first_name
                    purchaser_last_name purchaser_email customer_id)
          expect(ticket.keys).to eq(keys)
        end
      end

      it "returns the correct data" do
        JSON.parse(response.body).each_with_index do |ticket, index|
          ticket_atts = {
            id: db_tickets[index].id,
            reference: db_tickets[index].code,
            credential_redeemed: db_tickets[index].credential_redeemed,
            credential_type_id: db_tickets[index]&.company_ticket_type&.credential_type_id,
            purchaser_first_name: db_tickets[index]&.purchaser&.first_name,
            purchaser_last_name: db_tickets[index]&.purchaser&.last_name,
            purchaser_email: db_tickets[index]&.purchaser&.email,
            customer_id: db_tickets[index]&.assigned_profile&.id
          }
          expect(ticket_atts.as_json).to eq(ticket)
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

  describe "GET show" do
    context "with authentication" do
      before do
        @agreement = create(:company_event_agreement, event: event)
        @access = create(:access_catalog_item, event: event)
        @credential = create(:credential_type, catalog_item: @access)
        @ctt = create(:company_ticket_type, company_event_agreement: @agreement,
                                            event: event,
                                            credential_type: @credential)
        @ticket = create(:ticket, event: event, company_ticket_type: @ctt)
        @ticket2 = create(:ticket, event: event, company_ticket_type: @ctt)
        @profile = create(:profile, event: event)
        create(:credential_assignment, credentiable: @ticket,
                                       profile: @profile,
                                       aasm_state: "assigned")
        create(:credential_assignment, credentiable: @ticket2,
                                       profile: @profile,
                                       aasm_state: "unassigned")
        @customer = create(:customer, profile: @profile)
        @order = create(:customer_order, profile: @profile, catalog_item: @access)
        create(:online_order, counter: 1, customer_order: @order, redeemed: false)

        http_login(admin.email, admin.access_token)
      end

      describe "when ticket exists" do
        before(:each) do
          get :show, event_id: event.id, id: @ticket.id
        end

        it "returns a 200 status code" do
          expect(response.status).to eq(200)
        end

        it "returns the necessary keys" do
          ticket = JSON.parse(response.body)
          ticket_keys = %w(id reference credential_redeemed credential_type_id customer)
          customer_keys = %w(id autotopup_gateways credentials first_name last_name email orders)
          order_keys = %w(online_order_counter catalogable_id catalogable_type amount)

          expect(ticket.keys).to eq(ticket_keys)
          expect(ticket["customer"].keys).to eq(customer_keys)
          expect(ticket["customer"]["credentials"].map(&:keys).flatten.uniq).to eq(%w(id type))
          expect(ticket["customer"]["orders"].map(&:keys).flatten.uniq).to eq(order_keys)
        end

        it "returns the correct data" do
          customer = @ticket.assigned_profile.customer
          orders = @ticket.assigned_profile.customer_orders

          ticket = {
            id: @ticket.id,
            reference: @ticket.code,
            credential_redeemed: @ticket.credential_redeemed,
            credential_type_id: @ticket.company_ticket_type.credential_type_id,
            customer: {
              id:  @ticket.assigned_profile.id,
              autotopup_gateways: [],
              credentials: [{ id: @ticket.id, type: "ticket" }],
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

          expect(JSON.parse(response.body)).to eq(ticket.as_json)
        end
      end

      describe "when ticket doesn't exist" do
        it "returns a 404 status code" do
          get :show, event_id: event.id, id: (db_tickets.last.id + 10)
          expect(response.status).to eq(404)
        end
      end
    end

    context "without authentication" do
      it "returns a 401 status code" do
        get :show, event_id: event.id, id: db_tickets.last.id
        expect(response.status).to eq 401
      end
    end
  end

  describe "GET reference" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      describe "when ticket doesn't exist" do
        it "returns a 404 status code" do
          get :reference, event_id: event.id, id: "IdDoesntExist"
          expect(response.status).to eq 404
        end
      end

      describe "when ticket exists" do
        it "returns a 200 status code" do
          get :reference, event_id: event.id, id: db_tickets.last.code
          expect(response.status).to eq 200
        end
      end
    end
    context "without authentication" do
      it "returns a 401 status code" do
        get :reference, event_id: event.id, id: db_tickets.last.id
        expect(response.status).to eq 401
      end
    end
  end
end
