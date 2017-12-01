require 'rails_helper'

RSpec.describe "Test on Events view", js: true, type: :feature do
  before(:each) do
    @event_launched = create(:event, name: "Event Launched")
    @event_created = create(:event, state: "created", name: "Event Created")
    @event_closed = create(:event, state: "closed", name: "Event Closed")
    user = create(:user, role: "glowball")
    login_as(user, scope: :user)
    visit root_path
  end

  describe "filter events by state" do
    it "click on 'all' label" do
      find("#filters_all").click
      expect(page).to have_current_path(admins_events_path(status: 'all'))
      within '#event_list' do
        expect(page).to have_text @event_launched.name.to_s
        expect(page).to have_text @event_created.name.to_s
        expect(page).to have_text @event_closed.name.to_s
      end
    end

    it "click on 'created' label" do
      find("#filters_created").click
      expect(page).to have_current_path(admins_events_path(status: 'created'))
      within '#event_list' do
        expect(page).not_to have_text @event_launched.name.to_s
        expect(page).to have_text @event_created.name.to_s
        expect(page).not_to have_text @event_closed.name.to_s
      end
    end

    it "click on 'closed' label" do
      find("#filters_closed").click
      expect(page).to have_current_path(admins_events_path(status: 'closed'))
      within '#event_list' do
        expect(page).not_to have_text @event_launched.name.to_s
        expect(page).not_to have_text @event_created.name.to_s
        expect(page).to have_text @event_closed.name.to_s
      end
    end

    it "click on 'launched' label" do
      find("#filters_closed").click
      find("#filters_launched").click
      expect(page).to have_current_path(admins_events_path(status: 'launched'))
      within '#event_list' do
        expect(page).to have_text @event_launched.name.to_s
        expect(page).not_to have_text @event_created.name.to_s
        expect(page).not_to have_text @event_closed.name.to_s
      end
    end
  end

  describe "search event" do
    it "type event name" do
      find("#search_icon").click
      within("#event_search") { fill_in 'fixed-header-drawer-exp', with: @event_created.name.to_s }.native.send_keys(:return)
      within '#event_list' do
        expect(page).not_to have_text @event_launched.name.to_s
        expect(page).to have_text @event_created.name.to_s
        expect(page).not_to have_text @event_closed.name.to_s
      end
    end

    it "type non-existent event name" do
      find("#search_icon").click
      within("#event_search") { fill_in 'fixed-header-drawer-exp', with: "non-existent" }.native.send_keys(:return)
      within '#event_list' do
        expect(page).not_to have_text @event_launched.name.to_s
        expect(page).not_to have_text @event_created.name.to_s
        expect(page).not_to have_text @event_closed.name.to_s
      end
    end

    it "don't type event name" do
      find("#search_icon").click
      within("#event_search") { fill_in 'fixed-header-drawer-exp', with: "" }.native.send_keys(:return)
      within '#event_list' do
        expect(page).to have_text @event_launched.name.to_s
        expect(page).to have_text @event_created.name.to_s
        expect(page).to have_text @event_closed.name.to_s
      end
    end
  end

  describe "actions in events view" do
    it "select an event" do
      find("#event_#{@event_launched.id}_show").click
      expect(page).to have_current_path(admins_event_path(@event_launched))
    end
  end

  describe "create new event" do
    before do
      find("#floaty").hover
      find_link("new_event_link").click
    end

    it "path is correct" do
      expect(page).to have_current_path(new_admins_event_path)
    end

    it "filling name" do
      expect do
        within("#new_event") { fill_in 'event_name', with: "NewEvent" }
        find("input[name=commit]").click
      end.to change(Event, :count).by(1)
      expect(page).to have_current_path(admins_event_path("newevent"))
    end

    it "without filling name" do
      expect do
        find("input[name=commit]").click
      end.not_to change(Event, :count)
    end

    it "with incorrect date" do
      expect do
        within("#new_event") do
          fill_in 'event_name', with: "NewEvent"
          all('#event_start_date_2i option')[3].select_option
          all('#event_start_date_3i option')[5].select_option
          all('#event_end_date_2i option')[3].select_option
          all('#event_end_date_3i option')[4].select_option
        end
        find("input[name=commit]").click
      end.not_to change(Event, :count)
    end
  end
end
