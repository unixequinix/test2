require "spec_helper"

RSpec.describe Api::V1::Events::TicketsController, type: :controller do
  let(:event) { build(:event) }
  let(:admin) { Admin.first || create(:admin) }

  before do
    create_list(:ticket, 2, :with_purchaser, event: event)
  end

  describe "GET index" do
    context "with authentication" do
      before(:each) do
        http_login(admin.email, admin.access_token)
      end

      it "has a 200 status code" do
        get :index, event_id: Event.last.id
        expect(response.status).to eq 200
      end

      it "returns all the tickets" do
        get :index, event_id: event.id

        body = JSON.parse(response.body)
        tickets = body.map { |m| m["reference"] }

        event.tickets.map(&:code).each { |code|  expect(tickets).to include(code) }
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
          get :show, event_id: event.id, id: 999
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

        it "returns the customer_event_profile if it exists"
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

        it "returns the customer_event_profile if it exists"
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
