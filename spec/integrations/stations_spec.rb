require 'rails_helper'

RSpec.describe "Stations", type: :feature do
  let(:user) { create(:user, role: "glowball") }
  let(:event) { create(:event, name: "Test Event", state: "created") }

  before(:each) { login_as(user, scope: :user) }

  describe "of type Monetary" do
    let!(:station) { create(:station, event: event, category: "vendor", name: "Vendor1") }
    before(:each) { visit admins_event_stations_path(event, group: "monetary") }

    include_examples "UI stations"

    describe "Create new monetary station" do
      before(:each) do
        find("#floaty").click
        find_link("new_station_link").click
      end

      it "is located in correct path " do
        expect(page).to have_current_path(new_admins_event_station_path(event, group: "monetary"))
      end

      it "without filling name" do
        expect { find("input[name=commit]").click }.not_to change(Station, :count)
      end

      it "filling an existent name" do
        within("#new_station") { fill_in 'station_name', with: station.name.to_s }
        expect { find("input[name=commit]").click }.not_to change(Station, :count)
      end

      it "Bar" do
        within("#new_station") do
          fill_in 'station_name', with: "BAR"
          all('#station_category option')[0].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Vendor" do
        within("#new_station") do
          fill_in 'station_name', with: "VENDOR"
          all('#station_category option')[1].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Top up Refund" do
        within("#new_station") do
          fill_in 'station_name', with: "TOPUPREFUND"
          all('#station_category option')[2].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end
    end
  end

  describe "of type Access" do
    let!(:station) { create(:station, event: event, category: "box_office", name: "Box Office") }
    before(:each) { visit admins_event_stations_path(event, group: "access") }

    include_examples "UI stations"

    describe "Create new management station" do
      before(:each) do
        find("#floaty").click
        find_link("new_station_link").click
      end

      it "Ticket Validation" do
        within("#new_station") do
          fill_in 'station_name', with: "TESTTICKETVALIDATION"
          all('#station_category option')[0].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Checkin" do
        within("#new_station") do
          fill_in 'station_name', with: "TESTCHECKIN"
          all('#station_category option')[1].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Box Office" do
        within("#new_station") do
          fill_in 'station_name', with: "TESTBOXOFFICE"
          all('#station_category option')[2].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Staff Acreditation" do
        within("#new_station") do
          fill_in 'station_name', with: "TESTSTAFFACREDITATION"
          all('#station_category option')[3].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Access control" do
        within("#new_station") do
          fill_in 'station_name', with: "TESTACCESSCONTROL"
          all('#station_category option')[4].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end
    end
  end

  describe "of type Management" do
    let!(:station) { create(:station, event: event, category: "operator_permissions", name: "Operator Permissions") }
    before(:each) { visit admins_event_stations_path(event, group: "event_management") }

    include_examples "UI stations"

    describe "Create new access station" do
      before(:each) do
        find("#floaty").click
        find_link("new_station_link").click
      end
      it "Incident Report" do
        within("#new_station") do
          fill_in 'station_name', with: "INCIDENTREPORT"
          all('#station_category option')[0].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Exhibitor" do
        within("#new_station") do
          fill_in 'station_name', with: "EXHIBITOR"
          all('#station_category option')[1].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Customer Service" do
        within("#new_station") do
          fill_in 'station_name', with: "CUSTOMERSERVICE"
          all('#station_category option')[2].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Operator Permissions" do
        within("#new_station") do
          fill_in 'station_name', with: "OPERATORPERMISSIONS"
          all('#station_category option')[3].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Hospitality Top up" do
        within("#new_station") do
          fill_in 'station_name', with: "HOSPITALITYTOPUP"
          all('#station_category option')[4].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Cs topup refund" do
        within("#new_station") do
          fill_in 'station_name', with: "CSTOPUPREFUND"
          all('#station_category option')[5].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Cs topup refund" do
        within("#new_station") do
          fill_in 'station_name', with: "CSACCREDITATION"
          all('#station_category option')[6].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Cs accreditation" do
        within("#new_station") do
          fill_in 'station_name', with: "GTAGREPLACEMENT"
          all('#station_category option')[7].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end

      it "Yellow Card" do
        within("#new_station") do
          fill_in 'station_name', with: "YELLOWCARD"
          all('#station_category option')[8].select_option
        end
        expect { find("input[name=commit]").click }.to change(Station, :count).by(1)
        expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
      end
    end
  end
end
