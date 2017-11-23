require 'rails_helper'

RSpec.describe "Create new Accesses", js: true, type: :feature do
  let(:event) { create(:event, state: "launched") }
  let(:event_created) { create(:event, state: "created") }
  let(:user) { create(:user, role: :admin) }
  let(:access) { create(:access) }

  before(:each) do
    login_as(user, scope: :user)
  end

  describe "Creating accesses correctly" do
    it "Delete an Access on Access details view (EVENT CREATED)" do
      visit admins_event_accesses_path(event_created)
      find("#floaty").click
      find_link("new_access_link").click
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "DELETE"
        find("input[name=commit]").click
      end
      @access = event_created.accesses.last
      visit admins_event_access_path(event_created, @access)
      find("#floaty").click
      find("#delete").click
      page.accept_alert
      sleep(1)
      expect(event_created.accesses.count).to eq(0)
    end

    before(:each) do
      visit admins_event_accesses_path(event)
      find("#floaty").click
      find_link("new_access_link").click
    end

    it "Is located in /acceses" do
      expect(page).to have_current_path(new_admins_event_access_path(event))
    end

    it "Can be created by filling Name and Mode" do
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS"
      end

      expect { find("input[name=commit]").click }.to change(Access, :count).by(1)
      expect(page).to have_current_path admins_event_accesses_path(event)
    end

    it "Can not be created without filling Name" do
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
      end

      expect { find("input[name=commit]").click }.not_to change(Access, :count)
      expect(page).to have_current_path admins_event_accesses_path(event)
    end

    it "Shows the same number of Accesses that created" do
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS1"
      end
      expect { find("input[name=commit]").click }.to change(Access, :count).by(1)

      find("#floaty").click
      find_link("new_access_link").click
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS2"
      end
      expect { find("input[name=commit]").click }.to change(Access, :count).by(1)

      find("#floaty").click
      find_link("new_access_link").click
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS3"
      end
      expect { find("input[name=commit]").click }.to change(Access, :count).by(1)
      expect(event.accesses.count).to eq(3)
    end

    it "Checks Name and Mode of Accesses" do
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS1"
      end
      expect { find("input[name=commit]").click }.to change(Access, :count).by(1)
      expect(event.accesses.last.name).to eq("TESTACCESS1")
      @mode = event.accesses.last.mode
      expect(event.accesses.last.mode).to eq @mode

      visit admins_event_accesses_path(event)
      find("#floaty").click
      find_link("new_access_link").click
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS2"
      end
      expect { find("input[name=commit]").click }.to change(Access, :count).by(1)
      expect(event.accesses.last.name).to eq("TESTACCESS2")
      @mode = event.accesses.last.mode
      expect(event.accesses.last.mode).to eq @mode

      visit admins_event_accesses_path(event)
      find("#floaty").click
      find_link("new_access_link").click
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS3"
      end
      expect { find("input[name=commit]").click }.to change(Access, :count).by(1)
      expect(event.accesses.last.name).to eq("TESTACCESS3")
      @mode = event.accesses.last.mode
      expect(event.accesses.last.mode).to eq @mode
    end

    it "Redirect to Access details view" do
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "TESTACCESS"
      end
      expect { find("input[name=commit]").click }.to change(Access, :count).by(1)
      @access = event.accesses.last
      visit admins_event_access_path(event, @access)
      expect(page).to have_current_path admins_event_access_path(event, @access)
    end

    it "Delete an Access on Access details view (EVENT LAUNCHED)" do
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "DELETE"
        find("input[name=commit]").click
      end
      @access = event.accesses.last
      visit admins_event_access_path(event, @access)
      find("#floaty").click
      find("#delete").click
      page.accept_alert
      expect(event.accesses.count).not_to eq(0)
    end

    it "Cannot edit an Access and leave it without a name" do
      within("#new_access") do
        first('#access_mode option', minimum: 1).select_option
        fill_in 'access_name', with: "EDIT"
        find("input[name=commit]").click
      end
      @access = event.accesses.last
      visit admins_event_access_path(event, @access)
      find(".floaty-btn").click
      find("#edit").click
      fill_in 'access_name', with: ""
      find("input[name=commit]").click

      expect(page).not_to have_current_path admins_event_accesses_path(event)
    end
  end
end
