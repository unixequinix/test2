require 'rails_helper'

RSpec.describe "Accesses in the admin panel", type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:user) { create(:user, role: :admin) }
  let(:access) { create(:access, event: event) }

  before(:each) do
    login_as(user, scope: :user)
  end

  describe "delete: " do
    before { visit admins_event_access_path(event, access) }

    it "can be achieved if the event is in 'created' state" do
      event.update! state: "created"
      expect { find("#delete_access").click }.to change { event.accesses.count }.by(-1)
      expect(page).to have_current_path admins_event_accesses_path(event)
    end

    it "cannot be achieved if the event is in 'launched' state" do
      event.update! state: "launched"
      expect { find("#delete_access").click }.not_to change(event.accesses, :count)
      expect(page).to have_current_path admins_events_path
    end
  end

  describe "create: " do
    before { visit new_admins_event_access_path(event) }

    it "needs name and mode filled in" do
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS"
      end

      expect { find("input[name=commit]").click }.to change(Access, :count).by(1)
    end

    it "redirects to accesses#index" do
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS"
      end

      find("input[name=commit]").click
      expect(page).to have_current_path admins_event_accesses_path(event)
    end

    it "doesn't allow for nameless accesses" do
      within("#new_access") { first('#access_mode option', minimum: 1).select_option }
      expect { find("input[name=commit]").click }.not_to change(Access, :count)
    end
  end

  describe "index: " do
    before do
      create_list(:access, 5, event: event)
      visit new_admins_event_access_path(event)
    end

    it "shows the same number of Accesses present in event" do
      expect(event.accesses.count).to eq(5)
    end
  end

  describe "edit: " do
    it "cannot be edited as nameless" do
      visit edit_admins_event_access_path(event, access)

      within("#edit_access_#{access.id}") { fill_in 'access_name', with: "" }
      find("input[name=commit]").click

      expect(page).to have_current_path(admins_event_access_path(event, access))
    end
  end
end
