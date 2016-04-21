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

      it "has a 200 status code" do
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
            customer_id: db_tickets[index]&.assigned_customer_event_profile&.id
          }
          expect(ticket_atts.as_json).to eq(ticket)
        end
      end
    end

    context "without authentication" do
      it "has a 401 status code" do
        get :index, event_id: Event.last.id
        expect(response.status).to eq 401
      end
    end
  end

  describe "GET show" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      context "if ticket doesn't exist" do
        it "has a 404 status code" do
          get :show, event_id: event.id, id: (Ticket.last.id + 10)
          expect(response.status).to eq 404
        end
      end

      context "if ticket exists" do
        before(:each) do
          get :show, event_id: event.id, id: Ticket.last.id
        end

        it "has a 200 status code" do
          expect(response.status).to eq 200
        end

        it "returns the ticket specified" do
          body = JSON.parse(response.body)
          expect(body["reference"]).to eq(Ticket.last.code)
        end
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :show, event_id: event.id, id: Ticket.last.id
        expect(response.status).to eq 401
      end
    end
  end

  describe "GET reference" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      context "if ticket doesn't exist" do
        it "has a 404 status code" do
          get :reference, event_id: event.id, id: "IdDoesntExist"
          expect(response.status).to eq 404
        end
      end

      context "if ticket exists" do
        before(:each) do
          get :reference, event_id: event.id, id: Ticket.last.code
        end

        it "has a 200 status code" do
          expect(response.status).to eq 200
        end

        it "returns the ticket specified" do
          body = JSON.parse(response.body)
          expect(body["reference"]).to eq(Ticket.last.code)
        end
      end
    end
    context "without authentication" do
      it "has a 401 status code" do
        get :reference, event_id: event.id, id: Ticket.last.id
        expect(response.status).to eq 401
      end
    end
  end
end
