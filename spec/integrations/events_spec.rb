require 'rails_helper'
RSpec.describe "Events in the admin panel", type: :feature do
  let(:user) { create(:user, role: :admin) }
  let(:event) { create(:event, state: "created") }

  before { login_as(user, scope: :user) }

  describe "create:" do
    before { visit new_admins_event_path }

    context "a standard event" do
      it "can be done only filling in name" do
        within("#new_event") { fill_in 'event_name', with: "jakefest #{SecureRandom.hex(6).upcase}" }
        expect { find("input[name=commit]").click }.to change(Event, :count).by(1)
      end

      it "allows to select an event serie" do
        event_serie = create(:event_serie)
        visit new_admins_event_path

        name = "jakefest #{SecureRandom.hex(6).upcase}"
        within("#new_event") { fill_in('event_name', with: name) }
        find("#event_event_serie_id").select(event_serie.name)
        expect { find("input[name=commit]").click }.to change(Event, :count).by(1)
        expect(Event.find_by(name: name).event_serie).to eql(event_serie)
      end

      it "allows to select a timezone" do
        name = "jakefest #{SecureRandom.hex(6).upcase}"
        within("#new_event") { fill_in('event_name', with: name) }
        find("#event_timezone").select("(GMT+00:00) UTC")
        expect { find("input[name=commit]").click }.to change(Event, :count).by(1)
        expect(Event.find_by(name: name).timezone).to eql("UTC")
      end
    end

    context "a sample event" do
      before do
        visit sample_event_admins_events_path
        @event = Event.last
      end

      it "creates and event and then redirects you to it" do
        expect(page).to have_current_path(admins_event_path(@event))
      end
    end

    context "by promoter" do
      before { user.promoter! }

      it "can create a standard event" do
        visit new_admins_event_path
        expect(page).to have_current_path(new_admins_event_path)
      end

      it "can create a sample event" do
        visit sample_event_admins_events_path
        expect(page).to have_current_path(admins_events_path)
      end
    end
  end
end
