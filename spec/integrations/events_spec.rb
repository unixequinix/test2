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

      it "allows to select a start date" do
        name = "jakefest #{SecureRandom.hex(6).upcase}"
        within("#new_event") { fill_in('event_name', with: name) }
        find("#event_start_date_1i").select("2016")
        find("#event_start_date_2i").select("January")
        find("#event_start_date_3i").select("1")
        expect { find("input[name=commit]").click }.to change(Event, :count).by(1)
        expect(Event.find_by(name: name).start_date.to_date).to eql(Date.new(2016, 1, 1))
      end

      it "allows to select an end date" do
        name = "jakefest #{SecureRandom.hex(6).upcase}"
        within("#new_event") { fill_in('event_name', with: name) }
        find("#event_end_date_1i").select("2020")
        find("#event_end_date_2i").select("January")
        find("#event_end_date_3i").select("1")
        expect { find("input[name=commit]").click }.to change(Event, :count).by(1)
        expect(Event.find_by(name: name).end_date.to_date).to eql(Date.new(2020, 1, 1))
      end
    end

    context "a sample event" do
      before do
        visit sample_event_admins_events_path
        @event = Event.last
      end

      it "creates and event and then redirects you to it" do
        expect(page).to have_current_path(edit_admins_event_path(@event))
      end

      it "allows to change the name" do
        within("#edit_event_#{@event.id}") { fill_in 'event_name', with: "somename" }
        expect { find("input[name=commit]").click }.to change { @event.reload.name }.to("somename")
        expect(page).to have_current_path(admins_event_path(@event))
      end
    end

    context "by promoter" do
      before { user.promoter! }

      it "cannot create a standard event" do
        visit new_admins_event_path
        expect(page).to have_current_path(admins_events_path)
      end

      it "cannot create a sample event" do
        visit sample_event_admins_events_path
        expect(page).to have_current_path(admins_events_path)
      end
    end
  end

  describe "delete:" do
    before { visit admins_event_path(event) }

    it "can be done only if state is created" do
      event.update! state: "created"
      expect { find("#delete_event_link").click }.to change(Event, :count).by(-1)
    end

    it "cannot be done if state is not 'created'" do
      event.update! state: "closed"
      expect { find("#delete_event_link").click }.not_to change(Event, :count)
    end
  end
end
