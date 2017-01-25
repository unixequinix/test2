require "spec_helper"

RSpec.feature "Gtag Assignation", type: :feature do
  let(:event) { create(:event, :gtag_assignation, :pre_event) }
  let(:customer) { create(:customer, event: event) }
  let(:valid_gtag) { create(:gtag, event: event, customer: customer) }
  let(:invalid_gtag) { create(:gtag, event: event, customer: customer) }
  let(:event_path) { customer_root_path(event) }

  describe "User wants to assign a gtag" do
    before do
      login_as(customer, scope: :customer)
      visit(event_path)
    end

    context "when gtag is valid and unregistered" do
      before do
        find("a", text: "Add Tag").click
        find(".cb-gtag_field").set(valid_gtag.tag_uid)
        click_button("Accept")
      end

      it "assigns the gtag" do
        customer.reload
        customer_gtag = customer.active_gtag
        expect(customer_gtag.tag_uid).to eq(valid_gtag.tag_uid)
        expect(page.body).to include(valid_gtag.tag_uid)
      end

      it "redirects to customer portal home page" do
        expect(current_path).to eq(event_path)
      end
    end

    context "when gtag is already assigned" do
      before do
        find("a", text: "Add Tag").click
        find(".cb-gtag_field").set(invalid_gtag.tag_uid)
        click_button("Accept")
      end

      it "doesn't assign the gtag" do
        expect(customer.active_gtag).to be_nil
        expect(page.body).to have_css(".error-message")
      end

      it "renders the same page" do
        expect(current_path).to eq(current_path)
      end
    end

    context "when gtag is blank" do
      before do
        find("a", text: "Add Tag").click
        click_button("Accept")
      end

      it "doesn't assign the gtag" do
        expect(customer.active_gtag).to be_nil
        expect(page.body).to have_css(".error-message")
      end

      it "renders the same page" do
        expect(current_path).to eq(current_path)
      end
    end
  end

  describe "Gtag assignation availability" do
    context "when event status is preevent" do
      before do
        login_as(customer, scope: :customer)
        visit(event_path)
      end

      context "when gtag assignation is enabled" do
        it "is available" do
          expect(page.body).to include("Add Tag")
        end
      end

      context "when gtag assignation is disabled" do
        before do
          event.update!(gtag_assignation: false)
          visit(event_path)
        end

        it "is unavailable" do
          expect(page.body).not_to include("Add Tag")
        end
      end
    end

    context "when event status is during event" do
      before { event.update!(state: "started") }
      context "when gtag assignation is enabled" do
        it "is available" do
          expect(page.body).not_to include("Add Tag")
        end
      end

      context "when gtag assignation is disabled" do
        before do
          event.update!(gtag_assignation: false)
          visit(event_path)
        end

        it "is unavailable" do
          expect(page.body).not_to include("Add Tag")
        end
      end
    end

    context "when event status is finished" do
      before { event.update!(state: "finished") }
      context "when gtag assignation is enabled" do
        it "is unavailable" do
          expect(page.body).not_to include("Add Tag")
        end
      end

      context "when gtag assignation is disabled" do
        before do
          event.update!(gtag_assignation: false)
          visit(event_path)
        end

        it "is unavailable" do
          expect(page.body).not_to include("Add Tag")
        end
      end
    end
  end
end
