
RSpec.shared_examples "UI stations" do
  describe "Create new station" do
    before(:each) do
      find("#floaty").click
      find_link("new_station_link").click
    end

    it "is located in correct path " do
      expect(page).to have_current_path(new_admins_event_station_path(event, group: station.group))
    end

    it "fails without filling name" do
      expect { find("input[name=commit]").click }.not_to change(Station, :count)
    end

    it "fails if name is already taken" do
      within("#new_station") { fill_in 'station_name', with: station.name.to_s }
      expect { find("input[name=commit]").click }.not_to change(Station, :count)
    end
  end

  describe "actions on station" do
    it "select a station" do
      click_link("station_#{station.id}")
      expect(page).to have_current_path(admins_event_station_path(event, station.id))
    end

    it "edit a station" do
      click_link("edit_#{station.id}")
      expect(page).to have_current_path(edit_admins_event_station_path(event, station.id))
      within("#edit_station_#{station.id}") { fill_in 'station_name', with: "BoxOffice2" }
      expect { find("input[name=commit]").click }.to change { station.reload.name }.to("BoxOffice2")
    end

    it "clone a station" do
      expect { click_link("copy_#{station.id}") }.to change(Station, :count).by(1)
      expect(page).to have_current_path(admins_event_station_path(event, Station.last.id))
    end

    it "delete a station" do
      expect { click_link("delete_#{station.id}") }.to change(Station, :count).by(-1)
    end
  end
end
