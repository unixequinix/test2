require "rails_helper"

RSpec.describe Api::V1::Events::TicketsController, type: :controller do
  let(:event) { create(:event, open_devices_api: true) }
  let(:user) { create(:user) }
  let(:db_tickets) { event.tickets }
  let(:params) { { event_id: event.id, app_version: "5.7.0" } }

  before do
    create_list(:ticket, 2, event: event, customer: create(:customer, event: event))
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(user.email, user.access_token)
        get :index, params: params
      end

      it "returns a 200 status code" do
        expect(response).to be_ok
      end

      it "returns the necessary keys" do
        JSON.parse(response.body).map do |ticket|
          keys = %w[reference redeemed purchaser_first_name purchaser_last_name purchaser_email banned updated_at ticket_type_id customer_id]
          expect(ticket.keys).to eq(keys)
        end
      end

      it "returns the correct data" do
        JSON.parse(response.body).each do |list_ticket|
          ticket = db_tickets[db_tickets.index { |t| t.code == list_ticket["reference"] }]
          expect(list_ticket["reference"]).to eq(ticket.code)
          expect(list_ticket["redeemed"]).to eq(ticket.redeemed)
          expect(list_ticket["banned"]).to eq(ticket.banned?)
          expect(list_ticket["customer_id"]).to eq(ticket&.customer&.id)
          updated_at = Time.zone.parse(list_ticket["updated_at"]).strftime("%Y-%m-%dT%T.%6N")
          expect(updated_at).to eq(ticket.updated_at.utc.strftime("%Y-%m-%dT%T.%6N"))
        end
      end
    end

    context "without authentication" do
      it "returns a 401 status code" do
        get :index, params: params
        expect(response).to be_unauthorized
      end
    end
  end

  describe "GET show" do
    context "with authentication" do
      before do
        @pack = create(:pack, :with_access, event: event)
        @access = @pack.catalog_items.accesses.first
        @ctt = create(:ticket_type, company: create(:company, event: event), event: event, catalog_item: @pack)
        @customer = create(:customer, event: event)
        @ticket = create(:ticket, event: event, ticket_type: @ctt, customer: @customer)
        order = create(:order, customer: @customer, status: "completed", event: event)
        @item = order.order_items.first

        http_login(user.email, user.access_token)
      end

      describe "when ticket exists" do
        before(:each) do
          get :show, params: params.merge(id: @ticket.code)
        end

        it "returns a 200 status code" do
          expect(response).to be_ok
        end

        it "works with id" do
          get :show, params: params.merge(id: @ticket.id)
          expect(response).to be_ok
        end

        it "works with code including email addresses" do
          ticket = create(:ticket, event: event, ticket_type: @ctt, customer: @customer, code: "foo2@hoeho.bar.com")
          get :show, params: params.merge(id: ticket.code)
          expect(response).to be_ok
        end

        it "returns the necessary keys" do
          ticket = JSON.parse(response.body)
          ticket_keys = %w[reference redeemed banned catalog_item_id catalog_item_type ticket_type_id customer purchaser_first_name purchaser_last_name purchaser_email]
          c_keys = %w[id first_name last_name email orders credentials]
          order_keys = %w[id counter catalog_item_id catalog_item_type amount status redeemed]

          expect(ticket.keys).to eq(ticket_keys)
          expect(ticket["customer"].keys).to eq(c_keys)
          expect(ticket["customer"]["orders"].map(&:keys).flatten.uniq).to eq(order_keys)
        end

        it "returns the correct data" do
          customer = @ticket.customer

          ticket = {
            reference: @ticket.code,
            redeemed: @ticket.redeemed,
            banned: @ticket.banned,
            catalog_item_id: @ticket.ticket_type.catalog_item.id,
            catalog_item_type: @ticket.ticket_type.catalog_item.class.to_s,
            ticket_type_id: @ticket.ticket_type_id,
            customer: {
              id:  @ticket.customer.id,
              first_name: customer.first_name,
              last_name: customer.last_name,
              email: customer.email,
              orders: [{ id: @item.id,
                         counter: @item.counter,
                         catalog_item_id: @item.catalog_item_id,
                         catalog_item_type: @item.catalog_item.class.to_s,
                         amount: @item.amount,
                         status: @item.order.status,
                         redeemed: @item.redeemed }],
              credentials: [{ reference: @ticket.code,
                              type: "ticket",
                              redeemed: @ticket.redeemed,
                              banned: @ticket.banned,
                              ticket_type_id: @ticket.ticket_type_id }]
            },
            purchaser_first_name: @ticket.purchaser_first_name,
            purchaser_last_name: @ticket.purchaser_last_name,
            purchaser_email: @ticket.purchaser_email
          }

          expect(JSON.parse(response.body)).to eq(ticket.as_json)
        end
      end

      describe "when ticket doesn't exist" do
        it "returns a 404 status code" do
          get :show, params: params.merge(id: db_tickets.last.id + 10)
          expect(response.status).to eq(404)
        end
      end
    end

    context "without authentication" do
      it "returns a 401 status code" do
        get :show, params: params.merge(id: db_tickets.last.id)
        expect(response).to be_unauthorized
      end
    end
  end
end
