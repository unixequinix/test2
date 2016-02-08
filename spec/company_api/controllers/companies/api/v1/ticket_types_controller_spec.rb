require "rails_helper"

RSpec.describe Companies::Api::V1::TicketTypesController, :type => :controller do
  before(:all) do
    @event = create(:event)
    @company1 = create(:company, event: @event)
    @company2 = create(:company, event: @event)

    5.times { create(:company_ticket_type, event: @event, company: @company1) }
    5.times { create(:company_ticket_type, event: @event, company: @company2) }
  end

  describe "GET index" do

    context "when authenticated" do
      before(:each) do
        http_login(@company1.name, @event.token)
      end

      it "returns 200 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(200)
      end

      it "returns only the ticket types for that company" do
        get :index, event_id: @event.id

        body = JSON.parse(response.body)
        ticket_types = body["ticket_types"].map { |m| m["name"] }

        expect(ticket_types).to match_array(CompanyTicketType.search_by_company_and_event(
                                                                @company1.name, @event).map(&:name))
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :index, event_id: @event.id

        expect(response.status).to eq(401)
      end
    end
  end

  describe "GET show" do
    context "when authenticated" do
      before(:each) do
        http_login(@company1.name, @event.token)
      end

      context "when the ticket type belongs to the company" do
        before(:each) do
          get :show, event_id: @event.id, id: CompanyTicketType.first.id
        end

        it "returns a 200 status code" do
          expect(response.status).to eq(200)
        end

        it "returns the correct ticket" do
          body = JSON.parse(response.body)
          expect(body["name"]).to eq(CompanyTicketType.first.name)
        end
      end

      context "when the ticket type doesn't belong to the company" do
        it "returns a 404 status code" do
          get :show, event_id: @event.id, id: CompanyTicketType.last.id
          expect(response.status).to eq(404)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        get :show, event_id: @event.id, id: CompanyTicketType.first.id

        expect(response.status).to eq(401)
      end
    end
  end

  describe "POST create" do
    context "when authenticated" do
      before(:each) do
        @company = Company.last.name
        http_login(@company1.name, @event.token)
      end

      context "when the request is valid" do

        it "increases the tickets in the database by 1" do
          expect {
            post :create, ticket_type: attributes_for(:company_ticket_type)
          }.to change(CompanyTicketType,:count).by(1)
        end

        it "returns a 201 status code" do
          post :create, ticket_type: attributes_for(:company_ticket_type)
          expect(response.status).to eq(201)
        end

        it "returns the created ticket type" do
          post :create, ticket_type: attributes_for(:company_ticket_type)

          body = JSON.parse(response.body)
          expect(body["name"]).to eq(CompanyTicketType.last.name)
        end
      end

      context "when the request is invalid" do
        it "returns a 400 status code" do
          post :create, ticket_type: { with: "Invalid attributes" }
          expect(response.status).to eq(400)
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        post :create, ticket_type: { with: "Some data" }
        expect(response.status).to eq(401)
      end
    end
  end

  describe "PATCH update" do
    context "when authenticated" do
      before(:each) do
        @company = Company.last.name
        @ticket_type = CompanyTicketType.first
        http_login(@company1.name, @event.token)
      end

      context "when the request is valid" do
        before(:each) do
          @params = { name: "New ticket type"}
        end

        it "changes ticket type's attributes" do
          put :update, id: @ticket_type, ticket_type: @params
          @ticket_type.reload
          expect(@ticket_type.name).to eq("New ticket type")
        end

        it "returns a 200 code status" do
          put :update, id: @ticket_type, ticket_type: @params
          expect(response.status).to eq(200)
        end

        it "returns the updated ticket" do
          put :update, id: @ticket_type, ticket_type: @params
          body = JSON.parse(response.body)
          @ticket_type.reload
          expect(body["name"]).to eq(@ticket_type.name)
        end
      end

      context "when the request is invalid" do
        it "returns a 400 status code" do
          put :update, id: @ticket_type,
                       ticket_type: { name: nil, company_ticket_type_ref: "AA123" }
          expect(response.status).to eq(400)
        end

        it "doesn't change ticket's attributes" do
          put :update, id: @ticket_type,
                       ticket_type: { name: nil, company_ticket_type_ref: "AA123" }
          @ticket_type.reload
          expect(@ticket_type.company_ticket_type_ref).not_to eq("AA123")
        end
      end
    end

    context "when not authenticated" do
      it "returns a 401 status code" do
        put :update, id: CompanyTicketType.first, ticket_type: { name: "AA123" }
        expect(response.status).to eq(401)
      end
    end
  end
end
