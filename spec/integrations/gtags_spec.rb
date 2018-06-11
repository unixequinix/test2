require 'rails_helper'

RSpec.describe "GTags in the admin panel", type: :feature do
  let(:event) { create(:event, name: "EventoGTags", state: "launched") }
  let(:user) { create(:user, role: "admin") }
  let(:customer) { create(:customer, event: event) }
  let!(:gtag) { create(:gtag, customer: customer, event: event) }

  before(:each) do
    login_as(user, scope: :user)
  end

  describe "create: " do
    before { visit new_admins_event_gtag_path(event) }

    it "cannot be created without filling Tag Uid" do
      expect { find("input[name=commit]").click }.not_to change(Gtag, :count)
    end

    it "can be created by filling Tag Uid with 8 characters minimum" do
      within("#new_gtag") { fill_in 'gtag_tag_uid', with: "GTAGTEST1" }
      expect { find("input[name=commit]").click }.to change(Gtag, :count).by(1)
    end

    it "cannot be created if Tag Uid doesn't have 8 characters minimum" do
      within("#new_gtag") { fill_in 'gtag_tag_uid', with: "GTAG" }
      expect { find("input[name=commit]").click }.not_to change(Gtag, :count)
    end

    it "can be created by filling Tag Uid and Ticket Type" do
      within("#new_gtag") do
        fill_in 'gtag_tag_uid', with: "GTAGTEST1"
        first('#gtag_ticket_type_id option', minimum: 1).select_option
      end
      expect { find("input[name=commit]").click }.to change(Gtag, :count).by(1)
      expect(page).to have_current_path admins_event_gtags_path(event, operator: false)
      expect(event.gtags.last.tag_uid).to eq("GTAGTEST1")
    end
  end

  describe "index: " do
    before { visit admins_event_gtags_path(event) }

    it "clicks on a GTag's Uid and redirects to GTag's transactions view" do
      click_link("gtag_#{gtag.id}_link")
      expect(page).to have_current_path(admins_event_gtag_path(event, gtag))
    end

    it "clicks on a Customer's name and redirects to Customer's transactions view" do
      click_link("customer_#{gtag.customer_id}_link")
      expect(page).to have_current_path(admins_event_customer_path(event, customer))
    end
  end

  describe "edit: " do
    before do
      @ticket_type = create(:ticket_type, event: event)
      visit edit_admins_event_gtag_path(event, gtag)
    end

    it "modify Ticket Type" do
      all('#gtag_ticket_type_id option', minimum: 1)[1].select_option
      expect { find("input[name=commit]").click }.to change { gtag.reload.ticket_type }.to(@ticket_type)
    end

    it "modify Tag UID" do
      fill_in 'gtag_tag_uid', with: "GTAGMOD1"
      expect { find("input[name=commit]").click }.to change { gtag.reload.tag_uid }.to("GTAGMOD1")
    end

    it "cannot modify Tag UID under 8 characters" do
      fill_in 'gtag_tag_uid', with: "1234"
      expect { find("input[name=commit]").click }.not_to change { gtag.reload.tag_uid }.from(gtag.tag_uid)
    end

    it "cannot have blank UID" do
      fill_in 'gtag_tag_uid', with: ""
      expect { find("input[name=commit]").click }.not_to change { gtag.reload.tag_uid }.from(gtag.tag_uid)
    end
  end

  describe "delete: " do
    before { visit admins_event_gtag_path(event, gtag) }

    it "can be achieved if event is in 'created' state" do
      event.update! state: "created"
      expect { click_link("delete") }.to change(Gtag, :count).by(-1)
    end

    it "cannot be achieved if event is in 'launched' state" do
      event.update! state: "launched"
      expect { click_link("delete") }.not_to change(Gtag, :count)
    end

    it "cannot be achieved if event is in 'closed' state" do
      event.update! state: "closed"
      expect { click_link("delete") }.not_to change(Gtag, :count)
    end
  end
end
