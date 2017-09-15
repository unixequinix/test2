require 'rails_helper'

RSpec.describe "Event lifecycle: ", type: :feature do
  let(:user) { create(:user, role: 0) }

  before :each do
    login_as(user, scope: :user)
    visit admins_events_path
    find("#floaty").click
  end

  describe "creation of a standard event" do
    before { find_link("new_event_link").click }

    it "is located in events/new" do
      expect(page).to have_current_path(new_admins_event_path)
    end

    it "can be done only filling name" do
      expect do
        within("#new_event") do
          fill_in 'event_name', with: "jakefest"
        end

        find("input[name=commit]").click
      end.to change(Event, :count).by(1)

      expect(page).to have_current_path(admins_event_path(Event.last))
    end
  end

  describe "creation of a sample event" do
    let(:event) { Event.last }

    before { find_link("sample_event_link").click }

    it "creates and event and then redirects you to it" do
      expect(page).to have_current_path(edit_admins_event_path(event))
    end

    it "allows to change the name" do
      expect do
        within("#edit_event_#{event.id}") do
          fill_in 'event_name', with: "jakefest"
        end

        find("input[name=commit]").click
      end.to change { event.reload.name }.to("jakefest")

      expect(page).to have_current_path(admins_event_path(event))
    end
  end

  describe "by promoter" do
    before { user.promoter! }

    it "cannot create a standard event" do
      find_link("new_event_link").click
      expect(page).to have_current_path(admins_events_path)
    end

    it "cannot create a sample event" do
      find_link("new_event_link").click
      expect(page).to have_current_path(admins_events_path)
    end
  end

  describe "destroying events" do
    let(:event) { create(:event, state: "created") }

    before do
      visit(admins_event_path(event))
      find("#floaty").click
    end

    it "can be done" do
      expect { find("#delete_event_link").click }.to change(Event, :count).by(-1)
    end

    it "can be done if the event is not 'created'" do
      event.update! state: "launched"
      expect { find("#delete_event_link").click }.not_to change(Event, :count)
    end
  end
end
