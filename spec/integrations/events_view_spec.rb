require 'rails_helper'

RSpec.describe "Test on Events view", type: :feature do
  let(:user) { create(:user, role: "glowball") }
  let!(:event) { create(:event, name: "Event Launched") }

  before(:each) do
    login_as(user, scope: :user)
    visit root_path
  end

  describe "filter events by state" do
    let!(:event_created) { create(:event, state: "created", name: "Event Created") }
    let!(:event_closed) { create(:event, state: "closed", name: "Event Closed") }

    it "click on 'all' label" do
      find("#filters_all").click
      expect(page).to have_current_path(admins_events_path(status: 'all'))
      within '#event_list' do
        expect(page).to have_text event.name
        expect(page).to have_text event_created.name
        expect(page).to have_text event_closed.name
      end
    end

    it "click on 'created' label" do
      find("#filters_created").click
      expect(page).to have_current_path(admins_events_path(status: 'created'))
      within '#event_list' do
        expect(page).not_to have_text event.name.to_s
        expect(page).to have_text event_created.name.to_s
        expect(page).not_to have_text event_closed.name.to_s
      end
    end

    it "click on 'closed' label" do
      find("#filters_closed").click
      expect(page).to have_current_path(admins_events_path(status: 'closed'))
      within '#event_list' do
        expect(page).not_to have_text event.name.to_s
        expect(page).not_to have_text event_created.name.to_s
        expect(page).to have_text event_closed.name.to_s
      end
    end

    it "click on 'launched' label" do
      find("#filters_closed").click
      find("#filters_launched").click
      expect(page).to have_current_path(admins_events_path(status: 'launched'))
      within '#event_list' do
        expect(page).to have_text event.name.to_s
        expect(page).not_to have_text event_created.name.to_s
        expect(page).not_to have_text event_closed.name.to_s
      end
    end
  end

  describe "actions in events view" do
    it "select an event" do
      click_link("event_#{event.id}_show")
      expect(page).to have_current_path(admins_event_path(event))
    end
  end

  describe "create new event" do
    before do
      click_link("new_event_link")
    end

    it "path is correct" do
      expect(page).to have_current_path(new_admins_event_path)
    end

    it "filling name" do
      within("#new_event") { fill_in 'event_name', with: "NewEvent" }
      expect { find("input[name=commit]").click }.to change(Event, :count).by(1)
      expect(page).to have_current_path(admins_event_path("newevent"))
    end

    it "without filling name" do
      expect { find("input[name=commit]").click }.not_to change(Event, :count)
    end

    it "with incorrect date" do
      within("#new_event") do
        fill_in 'event_name', with: "NewEvent"
        all('#event_start_date_2i option')[3].select_option
        all('#event_start_date_3i option')[5].select_option
        all('#event_end_date_2i option')[3].select_option
        all('#event_end_date_3i option')[4].select_option
      end
      expect { find("input[name=commit]").click }.not_to change(Event, :count)
    end
  end
end
